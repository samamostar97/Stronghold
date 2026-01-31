using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Stronghold.Application.IServices;

namespace Stronghold.API.Controllers;

[ApiController]
[Route("api/admin/leaderboard")]
[Authorize(Roles = "Admin")]
public class AdminLeaderboardController : ControllerBase
{
    private readonly IUserProgressService _progressService;

    public AdminLeaderboardController(IUserProgressService progressService)
    {
        _progressService = progressService;
    }

    [HttpGet]
    public async Task<IActionResult> GetLeaderboard()
    {
        var leaderboard = await _progressService.GetFullLeaderboardAsync();
        return Ok(leaderboard);
    }
}
