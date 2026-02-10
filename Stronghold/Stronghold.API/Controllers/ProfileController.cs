using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Stronghold.Application.Common;
using Stronghold.Application.DTOs.Response;
using Stronghold.Application.IServices;

namespace Stronghold.API.Controllers;

[ApiController]
[Route("api/profile")]
[Authorize]
public class ProfileController : UserControllerBase
{
    private readonly IUserProfileService _service;

    public ProfileController(IUserProfileService service)
    {
        _service = service;
    }

    // =====================
    // Profile endpoints
    // =====================

    [HttpGet]
    public async Task<ActionResult<UserProfileResponse>> GetProfile()
    {
        var userId = GetCurrentUserId();
        if (userId == null)
            return Unauthorized();

        var profile = await _service.GetProfileAsync(userId.Value);
        return Ok(profile);
    }

    [HttpPost("picture")]
    public async Task<ActionResult<string>> UploadPicture(IFormFile file)
    {
        var userId = GetCurrentUserId();
        if (userId == null)
            return Unauthorized();

        if (file == null || file.Length == 0)
            return BadRequest("Nije odabrana slika");

        var fileRequest = new FileUploadRequest
        {
            FileStream = file.OpenReadStream(),
            FileName = file.FileName,
            ContentType = file.ContentType,
            FileSize = file.Length
        };

        var imageUrl = await _service.UploadProfilePictureAsync(userId.Value, fileRequest);
        return Ok(new { url = imageUrl });
    }

    [HttpDelete("picture")]
    public async Task<IActionResult> DeletePicture()
    {
        var userId = GetCurrentUserId();
        if (userId == null)
            return Unauthorized();

        await _service.DeleteProfilePictureAsync(userId.Value);
        return NoContent();
    }

    // =====================
    // Membership history
    // =====================

    [HttpGet("membership-history")]
    public async Task<ActionResult<IEnumerable<MembershipPaymentResponse>>> GetMembershipHistory()
    {
        var userId = GetCurrentUserId();
        if (userId == null)
            return Unauthorized();

        var history = await _service.GetMembershipPaymentHistoryAsync(userId.Value);
        return Ok(history);
    }

    // =====================
    // Progress tracking
    // =====================

    [HttpGet("progress")]
    public async Task<ActionResult<UserProgressResponse>> GetProgress()
    {
        var userId = GetCurrentUserId();
        if (userId == null)
            return Unauthorized();

        var progress = await _service.GetProgressAsync(userId.Value);
        return Ok(progress);
    }

    [Authorize(Roles = "Admin")]
    [HttpGet("progress/{userId}")]
    public async Task<ActionResult<UserProgressResponse>> GetUserProgress(int userId)
    {
        var progress = await _service.GetProgressAsync(userId);
        return Ok(progress);
    }

    // =====================
    // Leaderboard
    // =====================

    [HttpGet("leaderboard")]
    public async Task<ActionResult<List<LeaderboardEntryResponse>>> GetLeaderboard()
    {
        var leaderboard = await _service.GetLeaderboardAsync(5);
        return Ok(leaderboard);
    }

    [Authorize(Roles = "Admin")]
    [HttpGet("leaderboard/full")]
    public async Task<ActionResult<List<LeaderboardEntryResponse>>> GetFullLeaderboard()
    {
        var leaderboard = await _service.GetFullLeaderboardAsync();
        return Ok(leaderboard);
    }
}
