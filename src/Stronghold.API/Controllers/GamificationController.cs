using MediatR;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Stronghold.Application.Features.Gamification.GetLeaderboard;
using Stronghold.Application.Features.Gamification.GetMyGamification;

namespace Stronghold.API.Controllers;

[ApiController]
[Authorize]
public class GamificationController : ControllerBase
{
    private readonly IMediator _mediator;

    public GamificationController(IMediator mediator)
    {
        _mediator = mediator;
    }

    [HttpGet("api/leaderboard")]
    public async Task<IActionResult> GetLeaderboard([FromQuery] GetLeaderboardQuery query)
    {
        var result = await _mediator.Send(query);
        return Ok(result);
    }

    [HttpGet("api/users/me/gamification")]
    public async Task<IActionResult> GetMyGamification()
    {
        var result = await _mediator.Send(new GetMyGamificationQuery());
        return Ok(result);
    }
}
