using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
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
    }
}
