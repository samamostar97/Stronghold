using Stronghold.Application.Common;
using Stronghold.Application.Features.Users.DTOs;
using Stronghold.Core.Entities;

namespace Stronghold.Application.IRepositories;

public interface IUserRepository
{
    Task<PagedResult<User>> GetPagedAsync(UserFilter filter, CancellationToken cancellationToken = default);
    Task<User?> GetByIdAsync(int id, CancellationToken cancellationToken = default);
    Task<bool> ExistsByUsernameAsync(string username, int? excludeId = null, CancellationToken cancellationToken = default);
    Task<bool> ExistsByEmailAsync(string email, int? excludeId = null, CancellationToken cancellationToken = default);
    Task<bool> ExistsByPhoneAsync(string phoneNumber, int? excludeId = null, CancellationToken cancellationToken = default);
    Task AddAsync(User entity, CancellationToken cancellationToken = default);
    Task UpdateAsync(User entity, CancellationToken cancellationToken = default);
    Task DeleteAsync(User entity, CancellationToken cancellationToken = default);
}
