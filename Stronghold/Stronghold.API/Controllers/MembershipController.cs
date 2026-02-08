using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Stronghold.Application.Common;
using Stronghold.Application.DTOs.Request;
using Stronghold.Application.DTOs.Response;
using Stronghold.Application.Filters;
using Stronghold.Application.IServices;

namespace Stronghold.API.Controllers
{
    [ApiController]
    [Route("api/memberships")]
    [Authorize(Roles ="Admin")]
    public class MembershipController: ControllerBase
    {
        private readonly IMembershipService _membershipService;
        public MembershipController(IMembershipService membershipService)
        {
            _membershipService = membershipService;
        }
        [HttpPost]
        public async Task<ActionResult<MembershipResponse>> AssignMembershipAsync([FromBody]AssignMembershipRequest request)
        {
            var result = await _membershipService.AssignMembership(request);
            return Ok(result);
        }
        [HttpPatch]
        public async Task<ActionResult> RevokeMembershipAsync([FromQuery] int id)
        {
            var result = await _membershipService.RevokeMembership(id);
            return Ok(result);
        }
        [HttpGet("{userId}/history")]
        public async Task<ActionResult<PagedResult<MembershipPaymentResponse>>> GetPayments(int userId, [FromQuery] MembershipQueryFilter filter)
        {
            var result = await _membershipService.GetPaymentsAsync(userId, filter);
            return Ok(result);
        }
        [HttpGet("active-members")]
        public async Task<ActionResult<PagedResult<ActiveMemberResponse>>> GetActiveMembers([FromQuery] ActiveMemberQueryFilter filter)
        {
            var result = await _membershipService.GetActiveMembersAsync(filter);
            return Ok(result);
        }
    }
}
