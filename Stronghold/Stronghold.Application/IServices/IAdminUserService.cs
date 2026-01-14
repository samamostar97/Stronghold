using Stronghold.Application.Common;
using Stronghold.Application.DTOs.AdminUsersDTO;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Stronghold.Application.IServices
{
    public interface IAdminUserService
    {
        Task<PagedResult<AdminUserTableRowDTO>> GetUsersAsync(string? search, PaginationRequest pagination);
        Task<AdminUserDetailsDTO?> GetByIdAsync(int id);

        Task<int> CreateAsync(AdminCreateUserDTO dto);
        Task<bool> UpdateAsync(int id, AdminUpdateUserDTO dto);

        Task<bool> SoftDeleteAsync(int id, int currentAdminId);
        Task<bool> RestoreAsync(int id);
    }
}
