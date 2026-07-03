using System.Text.Json;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.ChangeTracking;
using Microsoft.EntityFrameworkCore.Diagnostics;
using Stronghold.Application.Interfaces;
using Stronghold.Core.Entities;
using Stronghold.Core.Enums;

namespace Stronghold.Infrastructure.Data;

/// <summary>
/// Presrece sve CRUD operacije nad jednostavnim entitetima i snima snapshot
/// starog stanja (JSON) - osnova za undo u roku od 1 sat (Faza 17).
/// Narudzbe, uplate, clanarine i termini se NE loguju - oni imaju state machine
/// i vlastiti audit, a njihovo ponistavanje je regularna poslovna operacija.
/// </summary>
public class ActivityLogInterceptor : SaveChangesInterceptor
{
    /// <summary>Entiteti za koje se nudi undo.</summary>
    public static readonly Dictionary<string, Type> UndoableTypes = new()
    {
        [nameof(City)] = typeof(City),
        [nameof(MembershipPackage)] = typeof(MembershipPackage),
        [nameof(SupplementCategory)] = typeof(SupplementCategory),
        [nameof(Supplier)] = typeof(Supplier),
        [nameof(Supplement)] = typeof(Supplement),
        [nameof(Faq)] = typeof(Faq),
        [nameof(StaffMember)] = typeof(StaffMember),
        [nameof(Seminar)] = typeof(Seminar)
    };

    private readonly ICurrentUserService _currentUser;
    private readonly List<(EntityEntry Entry, ActivityLog Log)> _pendingInserts = new();
    private bool _suppressed;

    public ActivityLogInterceptor(ICurrentUserService currentUser)
    {
        _currentUser = currentUser;
    }

    /// <summary>Iskljucuje logovanje dok undo servis vraca staro stanje.</summary>
    public IDisposable Suppress() => new SuppressScope(this);

    public override ValueTask<InterceptionResult<int>> SavingChangesAsync(
        DbContextEventData eventData,
        InterceptionResult<int> result,
        CancellationToken cancellationToken = default)
    {
        var context = eventData.Context;
        var userId = _currentUser.UserIdOrNull;
        if (context == null || _suppressed || userId == null || !_currentUser.IsAdmin)
        {
            // seed i pozadinski poslovi nemaju prijavljenog korisnika - ne loguju se.
            // clanovi ne rade CRUD nad ovim entitetima; njihove izmjene su nuspojave
            // poslovnih operacija (npr. kupovina smanjuje zalihe) i ne idu u aktivnosti
            return base.SavingChangesAsync(eventData, result, cancellationToken);
        }

        var logs = new List<ActivityLog>();
        foreach (var entry in context.ChangeTracker.Entries().ToList())
        {
            if (!UndoableTypes.ContainsKey(entry.Metadata.ClrType.Name))
            {
                continue;
            }

            switch (entry.State)
            {
                case EntityState.Added:
                    // id postoji tek nakon snimanja - log se upisuje u SavedChangesAsync
                    _pendingInserts.Add((entry, NewLog(entry, ActivityAction.Create,
                        oldDataJson: null, userId.Value)));
                    break;
                case EntityState.Modified:
                    logs.Add(NewLog(entry, ActivityAction.Update,
                        SerializeOriginal(entry), userId.Value));
                    break;
                case EntityState.Deleted:
                    logs.Add(NewLog(entry, ActivityAction.Delete,
                        SerializeOriginal(entry), userId.Value));
                    break;
            }
        }

        if (logs.Count > 0)
        {
            context.AddRange(logs);
        }
        return base.SavingChangesAsync(eventData, result, cancellationToken);
    }

    public override async ValueTask<int> SavedChangesAsync(
        SaveChangesCompletedEventData eventData,
        int result,
        CancellationToken cancellationToken = default)
    {
        var context = eventData.Context;
        if (context != null && !_suppressed && _pendingInserts.Count > 0)
        {
            var pending = _pendingInserts.ToList();
            _pendingInserts.Clear();
            foreach (var (entry, log) in pending)
            {
                log.EntityId = (int)entry.Property("Id").CurrentValue!;
                log.EntityDisplay = ResolveDisplay(entry);
                context.Add(log);
            }
            _suppressed = true;
            try
            {
                await context.SaveChangesAsync(cancellationToken);
            }
            finally
            {
                _suppressed = false;
            }
        }
        return await base.SavedChangesAsync(eventData, result, cancellationToken);
    }

    private static ActivityLog NewLog(EntityEntry entry, ActivityAction action,
        string? oldDataJson, int userId)
    {
        return new ActivityLog
        {
            EntityName = entry.Metadata.ClrType.Name,
            EntityId = action == ActivityAction.Create
                ? 0
                : (int)entry.Property("Id").OriginalValue!,
            EntityDisplay = ResolveDisplay(entry),
            Action = action,
            OldDataJson = oldDataJson,
            PerformedByUserId = userId,
            Timestamp = DateTime.UtcNow
        };
    }

    /// <summary>Snapshot skalarnih vrijednosti PRIJE izmjene/brisanja - koristi ga undo.</summary>
    private static string SerializeOriginal(EntityEntry entry)
    {
        var values = new Dictionary<string, object?>();
        foreach (var property in entry.Properties)
        {
            values[property.Metadata.Name] = property.OriginalValue;
        }
        return JsonSerializer.Serialize(values);
    }

    private static string? ResolveDisplay(EntityEntry entry)
    {
        return entry.Entity switch
        {
            City city => city.Name,
            MembershipPackage package => package.Name,
            SupplementCategory category => category.Name,
            Supplier supplier => supplier.Name,
            Supplement supplement => supplement.Name,
            Faq faq => faq.Question,
            StaffMember staff => $"{staff.FirstName} {staff.LastName}",
            Seminar seminar => seminar.Topic,
            _ => null
        };
    }

    private sealed class SuppressScope : IDisposable
    {
        private readonly ActivityLogInterceptor _interceptor;

        public SuppressScope(ActivityLogInterceptor interceptor)
        {
            _interceptor = interceptor;
            _interceptor._suppressed = true;
        }

        public void Dispose() => _interceptor._suppressed = false;
    }
}
