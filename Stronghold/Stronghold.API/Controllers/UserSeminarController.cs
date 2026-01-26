using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Stronghold.Application.DTOs.AdminSeminarDTO;
using Stronghold.Application.DTOs.UserDTOs;
using Stronghold.Application.IServices;

namespace Stronghold.API.Controllers
{
    [ApiController]
    [Route("api/user/seminar")]
    [Authorize]
    public class UserSeminarController:UserControllerBase
    {
        private readonly IUserSeminarService _userSeminarService;
        public UserSeminarController(IUserSeminarService userSeminarService)
        {
            _userSeminarService= userSeminarService;
        }
        [HttpGet]
        public async Task<ActionResult<IEnumerable<UserSeminarDTO>>> GetSeminarsAsync()
        {
            var userId= GetCurrentUserId();
            if (userId == null)
                return Unauthorized();
            var result = await _userSeminarService.GetSeminarListAsync(userId.Value);
            return Ok(result);
        }
        [HttpPost("{Id}")]
        public async Task<ActionResult> AttendSeminar(int Id)
        {
            var userId=GetCurrentUserId();
            if(userId == null)
                return Unauthorized();
            await _userSeminarService.AttendSeminarAsync(userId.Value, Id);
            return NoContent();
        }
        [HttpDelete("{id}")]
        public async Task<ActionResult> CancelAttendment(int id)
        {
            var userId= GetCurrentUserId();
            if(userId==null)
                return Unauthorized();
            await _userSeminarService.CancelSeminarAttendAsync(userId.Value, id);
            return NoContent();
        }
    }
}
