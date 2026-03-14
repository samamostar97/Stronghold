using Microsoft.EntityFrameworkCore;
using Stronghold.Application.Interfaces;
using Stronghold.Domain.Entities;
using Stronghold.Infrastructure.Persistence;

namespace Stronghold.Infrastructure.Repositories;

public class GymVisitRepository : Repository<GymVisit>, IGymVisitRepository
{
    public GymVisitRepository(StrongholdDbContext context) : base(context) { }

    public async Task<GymVisit?> GetActiveByUserIdAsync(int userId)
    {
        return await QueryAll()
            .Include(v => v.User)
            .FirstOrDefaultAsync(v => v.UserId == userId && v.CheckOutAt == null);
    }
}
