using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Stronghold.Application.DTOs.UserDTOs;
using Stronghold.Application.IServices;

namespace Stronghold.API.Controllers
{
    [ApiController]
    [Route("api/user/review")]
    [Authorize]
    public class UserReviewController : UserControllerBase
    {
        private readonly IUserReviewService _userReviewService;
        public UserReviewController(IUserReviewService userReviewService)
        {
            _userReviewService = userReviewService;
        }
        [HttpGet]
        public async Task<ActionResult<IEnumerable<UserReviewsDTO>>> GetReviewListAsync()
        {
            var userId = GetCurrentUserId();
            if (userId == null)
                return Unauthorized();
            var result = await _userReviewService.GetReviewList(userId.Value);
            return Ok(result);
        }
        [HttpDelete("{id}")]
        public async Task<ActionResult> DeleteReviewAsync(int id)
        {
            var userId = GetCurrentUserId();
            if (userId == null)
                return Unauthorized();
            await _userReviewService.DeleteReviewAsync(userId.Value, id);
            return NoContent();
        }
    }
}
