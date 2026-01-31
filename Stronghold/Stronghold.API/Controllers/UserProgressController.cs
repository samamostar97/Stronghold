using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Stronghold.Application.IServices;

namespace Stronghold.API.Controllers;

[ApiController]
[Route("api/user/progress")]
[Authorize]
public class UserProgressController : UserControllerBase
{
    private readonly IUserProgressService _progressService;

    public UserProgressController(IUserProgressService progressService)
    {
        _progressService = progressService;
    }

    [HttpGet]
    public async Task<IActionResult> GetProgress()
    {
        var userId = GetCurrentUserId();
        if (userId == null)
            return Unauthorized(new { message = "Nevalidan token" });

        var progress = await _progressService.GetUserProgressAsync(userId.Value);
        return Ok(progress);
    }

    [HttpGet("leaderboard")]
    public async Task<IActionResult> GetLeaderboard()
    {
        var leaderboard = await _progressService.GetLeaderboardAsync(5);
        return Ok(leaderboard);
    }
}
