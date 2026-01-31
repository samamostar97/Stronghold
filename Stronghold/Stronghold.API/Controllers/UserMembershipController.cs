using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Stronghold.Application.DTOs.UserDTOs;
using Stronghold.Application.IServices;

namespace Stronghold.API.Controllers
{
    [ApiController]
    [Route("api/user/membership")]
    [Authorize]
    public class UserMembershipController: UserControllerBase
    {
        private readonly IUserMembershipService _userMembershipService;
        public UserMembershipController(IUserMembershipService userMembershipService)
        {
            _userMembershipService = userMembershipService;
        }
        [HttpGet]
        public async Task<ActionResult<IEnumerable<MembershipPaymentDTO>>> GetPaymentHistory()
        {
            var userId = GetCurrentUserId();
            if (userId == null)
                return Unauthorized();
            var result = await _userMembershipService.GetMembershipPaymentHistory(userId.Value);
            return Ok(result);
        }
    }
}
