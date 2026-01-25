using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Stronghold.Application.DTOs.UserDTOs;
using Stronghold.Application.IServices;
using System.Security.Claims;

namespace Stronghold.API.Controllers
{
    [ApiController]
    [Route("api/user/membership")]
    [Authorize]
    public class UserMembershipController: ControllerBase
    {
        private readonly IUserMembershipService _userMembershipService;
        public UserMembershipController(IUserMembershipService userMembershipService)
        {
            _userMembershipService = userMembershipService;
        }
        [HttpGet]
        public async Task<ActionResult<IEnumerable<MembershipPaymentDTO>>> GetPaymentHistory() 
        {
            var userIdClaim = User.FindFirst(ClaimTypes.NameIdentifier)?.Value;
            if (string.IsNullOrEmpty(userIdClaim) || !int.TryParse(userIdClaim, out var userId))
                return Unauthorized();
            var result = await _userMembershipService.GetMembershipPaymentHistory(userId);
            return Ok(result);
        }
    }
}
