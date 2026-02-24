using Microsoft.EntityFrameworkCore;
using Stronghold.Application.Common;
using Stronghold.Application.Features.Seminars.DTOs;
using Stronghold.Application.IRepositories;
using Stronghold.Core.Entities;
using Stronghold.Infrastructure.Data;

namespace Stronghold.Infrastructure.Repositories;

public class SeminarRepository : ISeminarRepository
{
    private const string StatusActive = "active";
    private const string StatusCancelled = "cancelled";
    private const string StatusFinished = "finished";

    private readonly StrongholdDbContext _context;

    public SeminarRepository(StrongholdDbContext context)
    {
        _context = context;
    }

    public async Task<PagedResult<Seminar>> GetPagedAsync(SeminarFilter filter, CancellationToken cancellationToken = default)
    {
        filter ??= new SeminarFilter();

        var query = _context.Seminars
            .AsNoTracking()
            .Where(x => !x.IsDeleted)
            .AsQueryable();

        if (!string.IsNullOrWhiteSpace(filter.Search))
        {
            var search = filter.Search.Trim().ToLower();
            query = query.Where(x =>
                x.SpeakerName.ToLower().Contains(search) ||
                x.Topic.ToLower().Contains(search));
        }

        var now = StrongholdTimeUtils.UtcNow;
        if (!string.IsNullOrWhiteSpace(filter.Status))
        {
            query = filter.Status.Trim().ToLowerInvariant() switch
            {
                StatusActive => query.Where(x => !x.IsCancelled && x.EventDate > now),
                StatusCancelled => query.Where(x => x.IsCancelled),
                StatusFinished => query.Where(x => !x.IsCancelled && x.EventDate <= now),
                _ => query
            };
        }
        else if (filter.IsCancelled.HasValue)
        {
            query = query.Where(x => x.IsCancelled == filter.IsCancelled.Value);
        }

        if (!string.IsNullOrWhiteSpace(filter.OrderBy))
        {
            query = filter.OrderBy.Trim().ToLowerInvariant() switch
            {
                "topic" => query.OrderBy(x => x.IsCancelled).ThenBy(x => x.Topic).ThenBy(x => x.Id),
                "topicdesc" => query.OrderBy(x => x.IsCancelled).ThenByDescending(x => x.Topic).ThenByDescending(x => x.Id),
                "speakername" => query.OrderBy(x => x.IsCancelled).ThenBy(x => x.SpeakerName).ThenBy(x => x.Id),
                "speakernamedesc" => query.OrderBy(x => x.IsCancelled).ThenByDescending(x => x.SpeakerName).ThenByDescending(x => x.Id),
                "eventdate" => query.OrderBy(x => x.IsCancelled).ThenBy(x => x.EventDate).ThenBy(x => x.Id),
                "eventdatedesc" => query.OrderBy(x => x.IsCancelled).ThenByDescending(x => x.EventDate).ThenByDescending(x => x.Id),
                "maxcapacity" => query.OrderBy(x => x.IsCancelled).ThenBy(x => x.MaxCapacity).ThenBy(x => x.Id),
                "maxcapacitydesc" => query.OrderBy(x => x.IsCancelled).ThenByDescending(x => x.MaxCapacity).ThenByDescending(x => x.Id),
                _ => query.OrderBy(x => x.IsCancelled).ThenByDescending(x => x.EventDate).ThenByDescending(x => x.Id)
            };
        }
        else
        {
            query = query.OrderBy(x => x.IsCancelled).ThenByDescending(x => x.EventDate).ThenByDescending(x => x.Id);
        }

        var totalCount = await query.CountAsync(cancellationToken);
        var items = await query
            .Skip((filter.PageNumber - 1) * filter.PageSize)
            .Take(filter.PageSize)
            .ToListAsync(cancellationToken);

        return new PagedResult<Seminar>
        {
            Items = items,
            TotalCount = totalCount,
            PageNumber = filter.PageNumber
        };
    }

    public Task<Seminar?> GetByIdAsync(int id, CancellationToken cancellationToken = default)
    {
        return _context.Seminars
            .AsNoTracking()
            .FirstOrDefaultAsync(x => x.Id == id && !x.IsDeleted, cancellationToken);
    }

    public Task<bool> ExistsAsync(int id, CancellationToken cancellationToken = default)
    {
        return _context.Seminars.AnyAsync(x => x.Id == id && !x.IsDeleted, cancellationToken);
    }

    public Task<bool> ExistsByTopicAndDateAsync(
        string topic,
        DateTime eventDate,
        int? excludeId = null,
        CancellationToken cancellationToken = default)
    {
        var normalizedTopic = topic.Trim().ToLower();
        return _context.Seminars.AnyAsync(
            x => !x.IsDeleted &&
                 x.Topic.ToLower() == normalizedTopic &&
                 x.EventDate == eventDate &&
                 (!excludeId.HasValue || x.Id != excludeId.Value),
            cancellationToken);
    }

    public Task<int> CountAttendeesAsync(int seminarId, CancellationToken cancellationToken = default)
    {
        return _context.SeminarAttendees.CountAsync(
            x => !x.IsDeleted && x.SeminarId == seminarId,
            cancellationToken);
    }

    public async Task<IReadOnlyDictionary<int, int>> GetAttendeeCountsAsync(
        IEnumerable<int> seminarIds,
        CancellationToken cancellationToken = default)
    {
        var ids = seminarIds.Distinct().ToList();
        if (ids.Count == 0)
        {
            return new Dictionary<int, int>();
        }

        return await _context.SeminarAttendees
            .AsNoTracking()
            .Where(x => !x.IsDeleted && ids.Contains(x.SeminarId))
            .GroupBy(x => x.SeminarId)
            .Select(g => new { SeminarId = g.Key, Count = g.Count() })
            .ToDictionaryAsync(x => x.SeminarId, x => x.Count, cancellationToken);
    }

    public async Task<IReadOnlyList<Seminar>> GetUpcomingSeminarsAsync(DateTime nowUtc, CancellationToken cancellationToken = default)
    {
        return await _context.Seminars
            .AsNoTracking()
            .Where(x => !x.IsDeleted && !x.IsCancelled && x.EventDate > nowUtc)
            .OrderBy(x => x.EventDate)
            .ThenBy(x => x.Id)
            .ToListAsync(cancellationToken);
    }

    public async Task<IReadOnlyCollection<int>> GetUserAttendingSeminarIdsAsync(
        int userId,
        IEnumerable<int> seminarIds,
        CancellationToken cancellationToken = default)
    {
        var ids = seminarIds.Distinct().ToList();
        if (ids.Count == 0)
        {
            return Array.Empty<int>();
        }

        var attendingIds = await _context.SeminarAttendees
            .AsNoTracking()
            .Where(x => !x.IsDeleted && x.UserId == userId && ids.Contains(x.SeminarId))
            .Select(x => x.SeminarId)
            .Distinct()
            .ToListAsync(cancellationToken);

        return attendingIds;
    }

    public Task<bool> IsUserAttendingAsync(int userId, int seminarId, CancellationToken cancellationToken = default)
    {
        return _context.SeminarAttendees.AnyAsync(
            x => !x.IsDeleted && x.UserId == userId && x.SeminarId == seminarId,
            cancellationToken);
    }

    public Task<SeminarAttendee?> GetAttendanceAsync(int userId, int seminarId, CancellationToken cancellationToken = default)
    {
        return _context.SeminarAttendees
            .AsNoTracking()
            .FirstOrDefaultAsync(
            x => !x.IsDeleted && x.UserId == userId && x.SeminarId == seminarId,
            cancellationToken);
    }

    public async Task<IReadOnlyList<SeminarAttendee>> GetAttendeesBySeminarIdAsync(
        int seminarId,
        bool includeUser = false,
        CancellationToken cancellationToken = default)
    {
        var query = _context.SeminarAttendees
            .AsNoTracking()
            .Where(x => !x.IsDeleted && x.SeminarId == seminarId)
            .AsQueryable();

        if (includeUser)
        {
            query = query.Include(x => x.User);
        }

        return await query
            .OrderBy(x => x.RegisteredAt)
            .ToListAsync(cancellationToken);
    }

    public async Task AddAttendeeAsync(SeminarAttendee entity, CancellationToken cancellationToken = default)
    {
        await _context.SeminarAttendees.AddAsync(entity, cancellationToken);
        await _context.SaveChangesAsync(cancellationToken);
    }

    public async Task DeleteAttendeeAsync(SeminarAttendee entity, CancellationToken cancellationToken = default)
    {
        entity.IsDeleted = true;
        _context.SeminarAttendees.Update(entity);
        await _context.SaveChangesAsync(cancellationToken);
    }

    public async Task AddAsync(Seminar entity, CancellationToken cancellationToken = default)
    {
        await _context.Seminars.AddAsync(entity, cancellationToken);
        await _context.SaveChangesAsync(cancellationToken);
    }

    public async Task UpdateAsync(Seminar entity, CancellationToken cancellationToken = default)
    {
        _context.Seminars.Update(entity);
        await _context.SaveChangesAsync(cancellationToken);
    }

    public async Task DeleteAsync(Seminar entity, CancellationToken cancellationToken = default)
    {
        entity.IsDeleted = true;
        _context.Seminars.Update(entity);
        await _context.SaveChangesAsync(cancellationToken);
    }
}
