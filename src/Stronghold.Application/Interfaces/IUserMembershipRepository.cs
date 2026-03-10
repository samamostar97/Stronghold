using Stronghold.Domain.Entities;

namespace Stronghold.Application.Interfaces;

public interface IUserMembershipRepository : IRepository<UserMembership>
{
    Task<UserMembership?> GetActiveByUserIdAsync(int userId);
    Task<List<UserMembership>> GetHistoryByUserIdAsync(int userId);
}
