using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Stronghold.Application.DTOs.Profile;
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

    public ProfileController(IProfileService profileService)
    {
        _profileService = profileService;
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

    [HttpGet("image")]
    public async Task<IActionResult> GetImage()
    {
        var (data, contentType) = await _profileService.GetImageAsync();
        return File(data, contentType);
    }
}
