using MediatR;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Stronghold.Application.Features.Notifications.Commands;
using Stronghold.Application.Features.Notifications.DTOs;
using Stronghold.Application.Features.Notifications.Queries;

namespace Stronghold.API.Controllers
{
    [ApiController]
    [Route("api/notifications")]
    [Authorize]
    public class NotificationController : ControllerBase
    {
        private readonly IMediator _mediator;

        public NotificationController(IMediator mediator)
        {
            _mediator = mediator;
        }

        [HttpGet("unread-count")]
        public async Task<ActionResult<int>> GetUnreadCount()
        {
            var count = await _mediator.Send(new GetAdminUnreadCountQuery());
            return Ok(count);
        }

        [HttpGet("recent")]
        public async Task<ActionResult<IReadOnlyList<NotificationResponse>>> GetRecent([FromQuery] int count = 20)
        {
            var list = await _mediator.Send(new GetRecentAdminNotificationsQuery { Count = count });
            return Ok(list);
        }

        [HttpPatch("{id}/read")]
        public async Task<IActionResult> MarkAsRead(int id)
        {
            await _mediator.Send(new MarkAdminNotificationAsReadCommand { Id = id });
            return NoContent();
        }

        [HttpPatch("read-all")]
        public async Task<IActionResult> MarkAllAsRead()
        {
            await _mediator.Send(new MarkAllAdminNotificationsAsReadCommand());
            return NoContent();
        }

        [HttpGet("my/unread-count")]
        public async Task<ActionResult<int>> GetMyUnreadCount()
        {
            var count = await _mediator.Send(new GetMyUnreadNotificationCountQuery());
            return Ok(count);
        }

        [HttpGet("my")]
        public async Task<ActionResult<IReadOnlyList<NotificationResponse>>> GetMyNotifications([FromQuery] int count = 20)
        {
            var list = await _mediator.Send(new GetMyNotificationsQuery { Count = count });
            return Ok(list);
        }

        [HttpPatch("my/{id}/read")]
        public async Task<IActionResult> MarkMyAsRead(int id)
        {
            await _mediator.Send(new MarkMyNotificationAsReadCommand { Id = id });
            return NoContent();
        }

        [HttpPatch("my/read-all")]
        public async Task<IActionResult> MarkAllMyAsRead()
        {
            await _mediator.Send(new MarkAllMyNotificationsAsReadCommand());
            return NoContent();
        }
    }
}
