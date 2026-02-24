using Stronghold.Application.Common;
using Stronghold.Application.Features.Visits.DTOs;
using Stronghold.Core.Entities;

namespace Stronghold.Application.IRepositories;

public interface IVisitRepository
{
    Task<PagedResult<GymVisit>> GetCurrentPagedAsync(VisitFilter filter, CancellationToken cancellationToken = default);
    Task<User?> GetUserByIdAsync(int userId, CancellationToken cancellationToken = default);
    Task<GymVisit?> GetByIdAsync(int visitId, CancellationToken cancellationToken = default);
    Task<bool> HasActiveVisitAsync(int userId, CancellationToken cancellationToken = default);
    Task<bool> HasActiveMembershipAsync(int userId, DateTime nowUtc, CancellationToken cancellationToken = default);
    Task AddAsync(GymVisit entity, CancellationToken cancellationToken = default);
    Task UpdateAsync(GymVisit entity, CancellationToken cancellationToken = default);
}
