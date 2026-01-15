using Stronghold.Application.DTOs.AdminSupplementsDTO;
using Stronghold.Application.IRepositories;
using Stronghold.Core.Entities;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Stronghold.Application.IServices
{
    public interface IAdminSupplementService
    {
        Task<IEnumerable<SupplementDTO>> GetSupplementsAsync(string? search);
        Task<SupplementDTO> GetSupplementByIdAsync(int id);

        Task<int> AddAsync(CreateSupplementDTO createSupplementDTO);
        Task<bool> UpdateAsync(int id, UpdateSupplementDTO updateSupplementDTO);
        Task<bool> SoftDeleteAsync(int id);

    }

}
