using Microsoft.EntityFrameworkCore;
using Stronghold.Application.Interfaces;
using Stronghold.Domain.Entities;
using Stronghold.Infrastructure.Persistence;

namespace Stronghold.Infrastructure.Repositories;

public class UserMembershipRepository : Repository<UserMembership>, IUserMembershipRepository
{
    public UserMembershipRepository(StrongholdDbContext context) : base(context) { }

    public async Task<UserMembership?> GetActiveByUserIdAsync(int userId)
    {
        return await QueryAll()
            .Include(m => m.User)
            .Include(m => m.MembershipPackage)
            .FirstOrDefaultAsync(m => m.UserId == userId && m.IsActive && m.EndDate > DateTime.UtcNow);
    }

    public async Task<List<UserMembership>> GetHistoryByUserIdAsync(int userId)
    {
        return await QueryAll()
            .Include(m => m.MembershipPackage)
            .Where(m => m.UserId == userId)
            .OrderByDescending(m => m.StartDate)
            .ToListAsync();
    }
}
