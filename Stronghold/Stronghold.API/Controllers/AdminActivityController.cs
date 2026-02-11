using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Stronghold.Application.DTOs.Response;
using Stronghold.Application.IServices;

namespace Stronghold.API.Controllers;

[ApiController]
[Route("api/admin-activities")]
[Authorize(Roles = "Admin")]
public class AdminActivityController : UserControllerBase
{
    private readonly IAdminActivityService _service;

    public AdminActivityController(IAdminActivityService service)
    {
        _service = service;
    }

    [HttpGet("recent")]
    public async Task<ActionResult<List<AdminActivityResponse>>> GetRecent([FromQuery] int count = 20)
    {
        return Ok(await _service.GetRecentAsync(count));
    }

    [HttpPost("{id:int}/undo")]
    public async Task<ActionResult<AdminActivityResponse>> Undo(int id)
    {
        var adminUserId = GetCurrentUserId();
        if (adminUserId == null)
            return Unauthorized();

        var result = await _service.UndoAsync(id, adminUserId.Value);
        return Ok(result);
    }
}
