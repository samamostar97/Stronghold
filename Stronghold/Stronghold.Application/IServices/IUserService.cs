using Stronghold.Application.Common;
using Stronghold.Application.DTOs.UserDTOs;
using Stronghold.Core.Entities;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Stronghold.Application.IServices
{
    public interface IUserService
    {
        Task<PagedResult<User>> SearchAsync(UserSearchRequest request);
        Task<User> GetByIdAsync(int id);
        Task<int> CreateAsync(UserInsertRequest request);
        Task UpdateAsync(int id, UpdateUserRequest request);
        Task DeleteAsync(int id);
    }
}
