using Stronghold.Application.Common;
using Stronghold.Application.DTOs.Request;
using Stronghold.Application.DTOs.Response;
using Stronghold.Application.Filters;

namespace Stronghold.Application.IServices
{
    public interface IMembershipService
    {
        Task<MembershipResponse> AssignMembership(AssignMembershipRequest request);
        Task<PagedResult<MembershipPaymentResponse>> GetPaymentsAsync(int userId, MembershipQueryFilter filter);
        Task<bool> RevokeMembership(int userId);
        Task<PagedResult<ActiveMemberResponse>> GetActiveMembersAsync(ActiveMemberQueryFilter filter);
    }
}
