using MediatR;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Stronghold.Application.Common;
using Stronghold.Application.Features.Profiles.Commands;
using Stronghold.Application.Features.Profiles.Queries;
using Stronghold.Application.Features.Profiles.DTOs;
using Stronghold.Application.Features.Memberships.DTOs;

namespace Stronghold.API.Controllers;

[ApiController]
[Route("api/profile")]
[Authorize]
public class ProfileController : ControllerBase
{
    private readonly IMediator _mediator;

    public ProfileController(IMediator mediator)
    {
        _mediator = mediator;
    }

    [HttpGet]
    public async Task<ActionResult<UserProfileResponse>> GetProfile()
    {
        var profile = await _mediator.Send(new GetMyProfileQuery());
        return Ok(profile);
    }

    [HttpPost("picture")]
    public async Task<ActionResult<string>> UploadPicture([FromForm] IFormFile file)
    {
        if (file == null || file.Length == 0)
            return BadRequest("Nije odabrana slika");

        var imageUrl = await _mediator.Send(new UploadMyProfilePictureCommand
        {
            FileRequest = new FileUploadRequest
            {
                FileStream = file.OpenReadStream(),
                FileName = file.FileName,
                ContentType = file.ContentType,
                FileSize = file.Length
            }
        });

        return Ok(new { url = imageUrl });
    }

    [HttpDelete("picture")]
    public async Task<IActionResult> DeletePicture()
    {
        await _mediator.Send(new DeleteMyProfilePictureCommand());
        return NoContent();
    }

    [HttpGet("membership-history")]
    public async Task<ActionResult<IReadOnlyList<MembershipPaymentResponse>>> GetMembershipHistory()
    {
        var history = await _mediator.Send(new GetMyMembershipHistoryQuery());
        return Ok(history);
    }

    [HttpGet("progress")]
    public async Task<ActionResult<UserProgressResponse>> GetProgress()
    {
        var progress = await _mediator.Send(new GetMyProgressQuery());
        return Ok(progress);
    }

    [HttpGet("progress/{userId}")]
    public async Task<ActionResult<UserProgressResponse>> GetUserProgress(int userId)
    {
        var progress = await _mediator.Send(new GetUserProgressQuery { UserId = userId });
        return Ok(progress);
    }

    [HttpGet("leaderboard")]
    public async Task<ActionResult<IReadOnlyList<LeaderboardEntryResponse>>> GetLeaderboard()
    {
        var leaderboard = await _mediator.Send(new GetLeaderboardQuery { Top = 5 });
        return Ok(leaderboard);
    }

    [HttpGet("leaderboard/full")]
    public async Task<ActionResult<IReadOnlyList<LeaderboardEntryResponse>>> GetFullLeaderboard()
    {
        var leaderboard = await _mediator.Send(new GetFullLeaderboardQuery());
        return Ok(leaderboard);
    }
}
