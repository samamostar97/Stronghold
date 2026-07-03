using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Stronghold.Application.Common;
using Stronghold.Application.DTOs.ActivityLogs;
using Stronghold.Application.Interfaces;
using Stronghold.Core;

namespace Stronghold.API.Controllers;

/// <summary>Nedavne aktivnosti (dashboard) sa mogucnoscu undo u roku 1h.</summary>
[ApiController]
[Route("api/activity-logs")]
[Authorize(Roles = Roles.Admin)]
public class ActivityLogsController : ControllerBase
{
    private readonly IActivityLogService _activityLogService;

    public ActivityLogsController(IActivityLogService activityLogService)
    {
        _activityLogService = activityLogService;
    }

    [HttpGet]
    public async Task<ActionResult<PagedResult<ActivityLogResponse>>> GetPaged(
        [FromQuery] BaseSearchObject search)
    {
        return Ok(await _activityLogService.GetPagedAsync(search));
    }

    [HttpPost("{id}/undo")]
    public async Task<IActionResult> Undo(int id)
    {
        await _activityLogService.UndoAsync(id);
        return NoContent();
    }
}
