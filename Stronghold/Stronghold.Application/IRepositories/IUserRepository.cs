using Stronghold.Application.Common;
using Stronghold.Application.DTOs.UserDTOs;
using Stronghold.Core.Entities;

namespace Stronghold.Application.IRepositories;

public interface IUserRepository : IRepository<User, int>
{
    Task<PagedResult<User>> SearchPagedAsync(UserSearchRequest request);
}
