using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Stronghold.Application.Common;
using Stronghold.Application.DTOs.Notifications;
using Stronghold.Application.Interfaces;

namespace Stronghold.API.Controllers;

/// <summary>
/// In-app notifikacije - mobile ih dohvata pollingom (auto-refresh bez rucnog refresha).
/// </summary>
[ApiController]
[Route("api/notifications")]
[Authorize]
public class NotificationsController : ControllerBase
{
    private readonly INotificationService _notificationService;

    public NotificationsController(INotificationService notificationService)
    {
        _notificationService = notificationService;
    }

    [HttpGet("my")]
    public async Task<ActionResult<PagedResult<NotificationResponse>>> GetMine([FromQuery] BaseSearchObject search)
    {
        return Ok(await _notificationService.GetMineAsync(search));
    }

    [HttpGet("my/unread-count")]
    public async Task<ActionResult<int>> GetUnreadCount()
    {
        return Ok(await _notificationService.GetUnreadCountAsync());
    }

    [HttpPut("{id}/read")]
    public async Task<IActionResult> MarkRead(int id)
    {
        await _notificationService.MarkReadAsync(id);
        return NoContent();
    }

    [HttpPut("read-all")]
    public async Task<IActionResult> MarkAllRead()
    {
        await _notificationService.MarkAllReadAsync();
        return NoContent();
    }
}
