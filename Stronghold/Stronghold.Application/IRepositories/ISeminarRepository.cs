using Stronghold.Application.Common;
using Stronghold.Application.Features.Seminars.DTOs;
using Stronghold.Core.Entities;

namespace Stronghold.Application.IRepositories;

public interface ISeminarRepository
{
    Task<PagedResult<Seminar>> GetPagedAsync(SeminarFilter filter, CancellationToken cancellationToken = default);
    Task<Seminar?> GetByIdAsync(int id, CancellationToken cancellationToken = default);
    Task<bool> ExistsAsync(int id, CancellationToken cancellationToken = default);
    Task<bool> ExistsByTopicAndDateAsync(
        string topic,
        DateTime eventDate,
        int? excludeId = null,
        CancellationToken cancellationToken = default);
    Task<int> CountAttendeesAsync(int seminarId, CancellationToken cancellationToken = default);
    Task<IReadOnlyDictionary<int, int>> GetAttendeeCountsAsync(
        IEnumerable<int> seminarIds,
        CancellationToken cancellationToken = default);
    Task<IReadOnlyList<Seminar>> GetUpcomingSeminarsAsync(DateTime nowUtc, CancellationToken cancellationToken = default);
    Task<IReadOnlyCollection<int>> GetUserAttendingSeminarIdsAsync(
        int userId,
        IEnumerable<int> seminarIds,
        CancellationToken cancellationToken = default);
    Task<bool> IsUserAttendingAsync(int userId, int seminarId, CancellationToken cancellationToken = default);
    Task<SeminarAttendee?> GetAttendanceAsync(int userId, int seminarId, CancellationToken cancellationToken = default);
    Task<IReadOnlyList<SeminarAttendee>> GetAttendeesBySeminarIdAsync(
        int seminarId,
        bool includeUser = false,
        CancellationToken cancellationToken = default);
    Task AddAttendeeAsync(SeminarAttendee entity, CancellationToken cancellationToken = default);
    Task DeleteAttendeeAsync(SeminarAttendee entity, CancellationToken cancellationToken = default);
    Task AddAsync(Seminar entity, CancellationToken cancellationToken = default);
    Task UpdateAsync(Seminar entity, CancellationToken cancellationToken = default);
    Task DeleteAsync(Seminar entity, CancellationToken cancellationToken = default);
}
