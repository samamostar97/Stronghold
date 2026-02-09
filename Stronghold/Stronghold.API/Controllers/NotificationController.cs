using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Stronghold.Application.DTOs.Response;
using Stronghold.Application.IServices;

namespace Stronghold.API.Controllers
{
    [ApiController]
    [Route("api/notifications")]
    [Authorize]
    public class NotificationController : UserControllerBase
    {
        private readonly INotificationService _service;

        public NotificationController(INotificationService service)
        {
            _service = service;
        }

        // Admin endpoints

        [HttpGet("unread-count")]
        [Authorize(Roles = "Admin")]
        public async Task<ActionResult<int>> GetUnreadCount()
        {
            var count = await _service.GetUnreadCountAsync();
            return Ok(count);
        }

        [HttpGet("recent")]
        [Authorize(Roles = "Admin")]
        public async Task<ActionResult<List<NotificationResponse>>> GetRecent([FromQuery] int count = 20)
        {
            var list = await _service.GetRecentAsync(count);
            return Ok(list);
        }

        [HttpPatch("{id}/read")]
        [Authorize(Roles = "Admin")]
        public async Task<IActionResult> MarkAsRead(int id)
        {
            await _service.MarkAsReadAsync(id);
            return NoContent();
        }

        [HttpPatch("read-all")]
        [Authorize(Roles = "Admin")]
        public async Task<IActionResult> MarkAllAsRead()
        {
            await _service.MarkAllAsReadAsync();
            return NoContent();
        }

        // User endpoints

        [HttpGet("my/unread-count")]
        public async Task<ActionResult<int>> GetMyUnreadCount()
        {
            var userId = GetCurrentUserId();
            if (userId == null) return Unauthorized();

            var count = await _service.GetUserUnreadCountAsync(userId.Value);
            return Ok(count);
        }

        [HttpGet("my")]
        public async Task<ActionResult<List<NotificationResponse>>> GetMyNotifications([FromQuery] int count = 20)
        {
            var userId = GetCurrentUserId();
            if (userId == null) return Unauthorized();

            var list = await _service.GetUserRecentAsync(userId.Value, count);
            return Ok(list);
        }

        [HttpPatch("my/{id}/read")]
        public async Task<IActionResult> MarkMyAsRead(int id)
        {
            var userId = GetCurrentUserId();
            if (userId == null) return Unauthorized();

            await _service.MarkUserNotificationAsReadAsync(userId.Value, id);
            return NoContent();
        }

        [HttpPatch("my/read-all")]
        public async Task<IActionResult> MarkAllMyAsRead()
        {
            var userId = GetCurrentUserId();
            if (userId == null) return Unauthorized();

            await _service.MarkAllUserNotificationsAsReadAsync(userId.Value);
            return NoContent();
        }
    }
}
