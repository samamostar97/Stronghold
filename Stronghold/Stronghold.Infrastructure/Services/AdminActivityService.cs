using System.Reflection;
using Microsoft.EntityFrameworkCore;
using Stronghold.Application.DTOs.Response;
using Stronghold.Application.IServices;
using Stronghold.Core.Entities;
using Stronghold.Infrastructure.Common;
using Stronghold.Infrastructure.Data;

namespace Stronghold.Infrastructure.Services;

public class AdminActivityService : IAdminActivityService
{
    private const string AddActionType = "add";
    private const string DeleteActionType = "delete";
    private static readonly TimeSpan UndoWindow = TimeSpan.FromHours(1);

    private static readonly Dictionary<string, string> EntityLabels = new(StringComparer.OrdinalIgnoreCase)
    {
        ["User"] = "korisnik",
        ["Trainer"] = "trener",
        ["Nutritionist"] = "nutricionista",
        ["Supplement"] = "suplement",
        ["SupplementCategory"] = "kategorija",
        ["Supplier"] = "dobavljac",
        ["FAQ"] = "faq",
        ["Seminar"] = "seminar",
        ["Review"] = "recenzija",
        ["Appointment"] = "termin",
        ["MembershipPackage"] = "paket clanarine"
    };

    private readonly StrongholdDbContext _context;

    public AdminActivityService(StrongholdDbContext context)
    {
        _context = context;
    }

    public async Task LogAddAsync(int adminUserId, string adminUsername, string entityType, int entityId)
    {
        var now = DateTimeUtils.UtcNow;
        var normalizedEntityType = entityType?.Trim();
        if (string.IsNullOrWhiteSpace(normalizedEntityType))
            return;

        var label = EntityLabels.TryGetValue(normalizedEntityType, out var mappedLabel)
            ? mappedLabel
            : normalizedEntityType.ToLowerInvariant();

        var activity = new AdminActivityLog
        {
            AdminUserId = adminUserId,
            AdminUsername = string.IsNullOrWhiteSpace(adminUsername) ? $"admin-{adminUserId}" : adminUsername,
            ActionType = AddActionType,
            EntityType = normalizedEntityType,
            EntityId = entityId,
            Description = $"Dodan {label} (ID: {entityId})",
            UndoAvailableUntil = now.Add(UndoWindow),
            IsUndone = false
        };

        _context.AdminActivityLogs.Add(activity);
        await _context.SaveChangesAsync();
    }

    public async Task LogDeleteAsync(int adminUserId, string adminUsername, string entityType, int entityId)
    {
        var now = DateTimeUtils.UtcNow;
        var normalizedEntityType = entityType?.Trim();
        if (string.IsNullOrWhiteSpace(normalizedEntityType))
            return;

        var label = EntityLabels.TryGetValue(normalizedEntityType, out var mappedLabel)
            ? mappedLabel
            : normalizedEntityType.ToLowerInvariant();

        var activity = new AdminActivityLog
        {
            AdminUserId = adminUserId,
            AdminUsername = string.IsNullOrWhiteSpace(adminUsername) ? $"admin-{adminUserId}" : adminUsername,
            ActionType = DeleteActionType,
            EntityType = normalizedEntityType,
            EntityId = entityId,
            Description = $"Obrisan {label} (ID: {entityId})",
            UndoAvailableUntil = now.Add(UndoWindow),
            IsUndone = false
        };

        _context.AdminActivityLogs.Add(activity);
        await _context.SaveChangesAsync();
    }

    public async Task<List<AdminActivityResponse>> GetRecentAsync(int count = 20)
    {
        var safeCount = Math.Clamp(count, 1, 100);
        var now = DateTimeUtils.UtcNow;

        var activities = await _context.AdminActivityLogs
            .AsNoTracking()
            .OrderByDescending(x => x.CreatedAt)
            .Take(safeCount)
            .ToListAsync();

        var result = new List<AdminActivityResponse>(activities.Count);
        foreach (var activity in activities)
        {
            var canUndo = await CanUndoActivityAsync(activity, now);
            result.Add(new AdminActivityResponse
            {
                Id = activity.Id,
                ActionType = activity.ActionType,
                EntityType = activity.EntityType,
                EntityId = activity.EntityId,
                Description = activity.Description,
                AdminUsername = activity.AdminUsername,
                CreatedAt = activity.CreatedAt,
                UndoAvailableUntil = activity.UndoAvailableUntil,
                IsUndone = activity.IsUndone,
                CanUndo = canUndo
            });
        }

        return result;
    }

    public async Task<AdminActivityResponse> UndoAsync(int id, int adminUserId)
    {
        var now = DateTimeUtils.UtcNow;
        var activity = await _context.AdminActivityLogs.FirstOrDefaultAsync(x => x.Id == id);
        if (activity == null)
            throw new KeyNotFoundException("Aktivnost nije pronadjena.");

        if (activity.IsUndone)
            throw new InvalidOperationException("Aktivnost je vec ponistena.");

        if (activity.UndoAvailableUntil < now)
            throw new InvalidOperationException("Istekao je period za undo (1 sat).");

        var entityType = ResolveEntityType(activity.EntityType);
        var entity = await FindEntityIgnoreFiltersAsync(entityType, activity.EntityId);
        if (entity == null)
            throw new InvalidOperationException("Zapis vise ne postoji.");

        if (string.Equals(activity.ActionType, DeleteActionType, StringComparison.OrdinalIgnoreCase))
        {
            if (!entity.IsDeleted)
                throw new InvalidOperationException("Zapis je vec aktivan.");

            entity.IsDeleted = false;
        }
        else if (string.Equals(activity.ActionType, AddActionType, StringComparison.OrdinalIgnoreCase))
        {
            if (entity.IsDeleted)
                throw new InvalidOperationException("Zapis je vec obrisan.");

            entity.IsDeleted = true;
        }
        else
        {
            throw new InvalidOperationException("Za ovu aktivnost undo nije podrzan.");
        }

        activity.IsUndone = true;
        activity.UndoneAt = now;
        activity.UndoneByUserId = adminUserId;

        try
        {
            await _context.SaveChangesAsync();
        }
        catch (DbUpdateException)
        {
            throw new InvalidOperationException("Undo nije moguc zbog konflikta podataka.");
        }

        return new AdminActivityResponse
        {
            Id = activity.Id,
            ActionType = activity.ActionType,
            EntityType = activity.EntityType,
            EntityId = activity.EntityId,
            Description = activity.Description,
            AdminUsername = activity.AdminUsername,
            CreatedAt = activity.CreatedAt,
            UndoAvailableUntil = activity.UndoAvailableUntil,
            IsUndone = activity.IsUndone,
            CanUndo = false
        };
    }

    private Type ResolveEntityType(string entityTypeName)
    {
        var clrType = _context.Model
            .GetEntityTypes()
            .Select(x => x.ClrType)
            .FirstOrDefault(x =>
                typeof(BaseEntity).IsAssignableFrom(x) &&
                x.Name.Equals(entityTypeName, StringComparison.OrdinalIgnoreCase));

        if (clrType == null)
            throw new InvalidOperationException("Za ovu aktivnost undo nije podrzan.");

        return clrType;
    }

    private async Task<BaseEntity?> FindEntityIgnoreFiltersAsync(Type entityClrType, int entityId)
    {
        var method = GetType()
            .GetMethod(nameof(FindEntityGenericAsync), BindingFlags.NonPublic | BindingFlags.Instance)!
            .MakeGenericMethod(entityClrType);

        var task = (Task<BaseEntity?>)method.Invoke(this, new object[] { entityId })!;
        return await task;
    }

    private async Task<BaseEntity?> FindEntityGenericAsync<TEntity>(int entityId)
        where TEntity : BaseEntity
    {
        return await _context.Set<TEntity>()
            .IgnoreQueryFilters()
            .FirstOrDefaultAsync(x => x.Id == entityId);
    }

    private async Task<bool> CanUndoActivityAsync(AdminActivityLog activity, DateTime now)
    {
        if (activity.IsUndone || activity.UndoAvailableUntil < now)
            return false;

        var isDelete = string.Equals(activity.ActionType, DeleteActionType, StringComparison.OrdinalIgnoreCase);
        var isAdd = string.Equals(activity.ActionType, AddActionType, StringComparison.OrdinalIgnoreCase);
        if (!isDelete && !isAdd)
            return false;

        Type entityType;
        try
        {
            entityType = ResolveEntityType(activity.EntityType);
        }
        catch
        {
            return false;
        }

        var entity = await FindEntityIgnoreFiltersAsync(entityType, activity.EntityId);
        if (entity == null)
            return false;

        return isDelete ? entity.IsDeleted : !entity.IsDeleted;
    }
}
