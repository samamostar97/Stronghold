using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Stronghold.Application.Common;
using Stronghold.Application.DTOs.Progress;
using Stronghold.Application.Interfaces;

namespace Stronghold.API.Controllers;

/// <summary>Leaderboard vide i admin (desktop) i clanovi (mobile).</summary>
[ApiController]
[Route("api/leaderboard")]
[Authorize]
public class LeaderboardController : ControllerBase
{
    private readonly IProgressService _progressService;

    public LeaderboardController(IProgressService progressService)
    {
        _progressService = progressService;
    }

    [HttpGet]
    public async Task<ActionResult<PagedResult<LeaderboardEntryResponse>>> Get([FromQuery] BaseSearchObject search)
    {
        return Ok(await _progressService.GetLeaderboardAsync(search));
    }
}
