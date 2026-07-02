using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Stronghold.Application.DTOs.Profile;
using Stronghold.Application.DTOs.Progress;
using Stronghold.Application.DTOs.Users;
using Stronghold.Application.Interfaces;

namespace Stronghold.API.Controllers;

/// <summary>
/// Podaci trenutno prijavljenog korisnika - id se uzima iz JWT tokena, nikad iz rute.
/// </summary>
[ApiController]
[Route("api/profile")]
[Authorize]
public class ProfileController : ControllerBase
{
    private readonly IProfileService _profileService;
    private readonly IProgressService _progressService;

    public ProfileController(IProfileService profileService, IProgressService progressService)
    {
        _profileService = profileService;
        _progressService = progressService;
    }

    [HttpGet]
    public async Task<ActionResult<UserResponse>> Get()
    {
        return Ok(await _profileService.GetAsync());
    }

    [HttpPut]
    public async Task<ActionResult<UserResponse>> Update(UpdateProfileRequest request)
    {
        return Ok(await _profileService.UpdateAsync(request));
    }

    [HttpPut("password")]
    public async Task<IActionResult> ChangePassword(ChangePasswordRequest request)
    {
        await _profileService.ChangePasswordAsync(request);
        return NoContent();
    }

    /// <summary>XP, nivo i analitika napretka trenutno prijavljenog clana.</summary>
    [HttpGet("progress")]
    public async Task<ActionResult<ProgressResponse>> GetProgress()
    {
        return Ok(await _progressService.GetMyProgressAsync());
    }

    [HttpGet("image")]
    public async Task<IActionResult> GetImage()
    {
        var (data, contentType) = await _profileService.GetImageAsync();
        return File(data, contentType);
    }
}
