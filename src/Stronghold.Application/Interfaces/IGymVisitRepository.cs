using Stronghold.Domain.Entities;

namespace Stronghold.Application.Interfaces;

public interface IGymVisitRepository : IRepository<GymVisit>
{
    Task<GymVisit?> GetActiveByUserIdAsync(int userId);
}
