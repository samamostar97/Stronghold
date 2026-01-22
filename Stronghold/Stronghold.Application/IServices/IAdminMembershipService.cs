using Stronghold.Application.Common;
using Stronghold.Application.DTOs.AdminUserMembershipsDTO;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Stronghold.Application.IServices
{
    public interface IAdminMembershipService
    {
        Task<MembershipDTO> AssignMembership(AssignMembershipRequest request);
        Task<PagedResult<MembershipPaymentsDTO>> GetPaymentsAsync(int userId, PaginationRequest pagination);
        Task<bool> RevokeMembership(int userId);

    }
}
