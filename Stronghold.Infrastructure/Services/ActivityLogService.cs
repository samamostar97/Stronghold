using System.Text.Json;
using Microsoft.EntityFrameworkCore;
using Stronghold.Application.Common;
using Stronghold.Application.DTOs.ActivityLogs;
using Stronghold.Application.Exceptions;
using Stronghold.Application.Interfaces;
using Stronghold.Core.Entities;
using Stronghold.Core.Enums;
using Stronghold.Infrastructure.Data;

namespace Stronghold.Infrastructure.Services;

public class ActivityLogService : IActivityLogService
{
    private static readonly TimeSpan UndoWindow = TimeSpan.FromHours(1);

    private readonly StrongholdDbContext _db;
    private readonly ActivityLogInterceptor _interceptor;

    public ActivityLogService(StrongholdDbContext db, ActivityLogInterceptor interceptor)
    {
        _db = db;
        _interceptor = interceptor;
    }

    public async Task<PagedResult<ActivityLogResponse>> GetPagedAsync(BaseSearchObject search)
    {
        var query = _db.ActivityLogs.AsNoTracking()
            .OrderByDescending(l => l.Timestamp);

        var totalCount = await query.CountAsync();
        var now = DateTime.UtcNow;
        var items = await query
            .Skip((search.Page - 1) * search.PageSize)
            .Take(search.PageSize)
            .Select(l => new ActivityLogResponse
            {
                Id = l.Id,
                EntityName = l.EntityName,
                EntityDisplay = l.EntityDisplay,
                EntityId = l.EntityId,
                Action = l.Action.ToString(),
                PerformedByName = l.PerformedBy.FirstName + " " + l.PerformedBy.LastName,
                Timestamp = l.Timestamp,
                UndoneAt = l.UndoneAt,
                CanUndo = l.UndoneAt == null && l.Timestamp > now.AddHours(-1)
            })
            .ToListAsync();

        return new PagedResult<ActivityLogResponse> { Items = items, TotalCount = totalCount };
    }

    public async Task UndoAsync(int id)
    {
        var log = await _db.ActivityLogs.FindAsync(id)
            ?? throw new NotFoundException("Aktivnost ne postoji.");

        if (log.UndoneAt != null)
        {
            throw new BusinessException("Ova akcija je već poništena.");
        }
        // rok od 1 sat se validira na backendu po timestampu zapisa
        if (log.Timestamp < DateTime.UtcNow - UndoWindow)
        {
            throw new BusinessException("Akcija se može poništiti samo u roku od 1 sat.");
        }
        if (!ActivityLogInterceptor.UndoableTypes.TryGetValue(log.EntityName, out var entityType))
        {
            throw new BusinessException("Undo nije dostupan za ovu vrstu zapisa.");
        }

        // vracanje starog stanja se ne loguje kao nova aktivnost
        using var suppression = _interceptor.Suppress();

        switch (log.Action)
        {
            case ActivityAction.Create:
                await UndoCreateAsync(entityType, log.EntityId);
                break;
            case ActivityAction.Update:
                await UndoUpdateAsync(entityType, log);
                break;
            case ActivityAction.Delete:
                UndoDelete(entityType, log);
                break;
        }

        log.UndoneAt = DateTime.UtcNow;
        try
        {
            await _db.SaveChangesAsync();
        }
        catch (DbUpdateException)
        {
            throw new BusinessException(
                "Poništavanje nije moguće - zapis u međuvremenu koriste drugi podaci.");
        }
    }

    private async Task UndoCreateAsync(Type entityType, int entityId)
    {
        var entity = await _db.FindAsync(entityType, entityId)
            ?? throw new BusinessException("Zapis je u međuvremenu obrisan.");
        _db.Remove(entity);
    }

    private async Task UndoUpdateAsync(Type entityType, ActivityLog log)
    {
        var entity = await _db.FindAsync(entityType, log.EntityId)
            ?? throw new BusinessException("Zapis je u međuvremenu obrisan.");
        var snapshot = DeserializeSnapshot(entityType, log);
        _db.Entry(entity).CurrentValues.SetValues(snapshot);
    }

    private void UndoDelete(Type entityType, ActivityLog log)
    {
        var snapshot = DeserializeSnapshot(entityType, log);
        // ponovni unos dobija novi id (identity kolona)
        _db.Entry(snapshot).Property("Id").CurrentValue = 0;
        _db.Add(snapshot);
    }

    private static object DeserializeSnapshot(Type entityType, ActivityLog log)
    {
        if (log.OldDataJson == null)
        {
            throw new BusinessException("Snapshot starog stanja ne postoji.");
        }
        return JsonSerializer.Deserialize(log.OldDataJson, entityType)
            ?? throw new BusinessException("Snapshot starog stanja nije čitljiv.");
    }
}
