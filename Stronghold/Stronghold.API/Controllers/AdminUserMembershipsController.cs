using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Stronghold.Application.Common;
using Stronghold.Application.DTOs.AdminUserMembershipsDTO;
using Stronghold.Application.IServices;
using Stronghold.Infrastructure.Services;
using System.Runtime.CompilerServices;

namespace Stronghold.API.Controllers
{
    [ApiController]
    [Route("api/admin/user/membership")]
    [Authorize(Roles ="Admin")]
    public class AdminUserMembershipsController: ControllerBase
    {
        private readonly IAdminMembershipService _adminMembershipService;
        public AdminUserMembershipsController(IAdminMembershipService adminMembershipService)
        {
            _adminMembershipService = adminMembershipService;
        }
        [HttpPost]
        public async Task<ActionResult<MembershipDTO>> AssignMembershipAsync([FromBody]AssignMembershipRequest request)
        {
            var result = await _adminMembershipService.AssignMembership(request);
            return Ok(result);
        }
        [HttpPatch]
        public async Task<ActionResult> RevokeMembershipAsync([FromQuery] int id)
        {
            var result = await _adminMembershipService.RevokeMembership(id);
            return Ok(result);
        }
        [HttpGet("{userId}/history")]
        public async Task<ActionResult<PagedResult<MembershipPaymentsDTO>>> GetPayments(
        int userId,
        [FromQuery] int pageNumber = 1,
        [FromQuery] int pageSize = 20)
        {
            var pagination = new PaginationRequest { PageNumber = pageNumber, PageSize = pageSize };
            var result = await _adminMembershipService.GetPaymentsAsync(userId, pagination);
            return Ok(result);
        }
    }
}
