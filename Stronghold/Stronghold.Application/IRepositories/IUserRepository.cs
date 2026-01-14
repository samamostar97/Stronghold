using Stronghold.Application.Common;
using Stronghold.Core.Entities;

namespace Stronghold.Application.IRepositories;

public interface IUserRepository : IRepository<User, int>
{
    Task<bool> UsernameExistsAsync(string username, int? excludeUserId = null);
    Task<bool> EmailExistsAsync(string email, int? excludeUserId = null);
}
