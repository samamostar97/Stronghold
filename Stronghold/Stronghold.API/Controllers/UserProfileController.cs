using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Stronghold.Application.Common;
using Stronghold.Application.IServices;

namespace Stronghold.API.Controllers;

[ApiController]
[Route("api/user/profile")]
[Authorize]
public class UserProfileController : UserControllerBase
{
    private readonly IUserProfileService _profileService;

    public UserProfileController(IUserProfileService profileService)
    {
        _profileService = profileService;
    }

    [HttpPost("picture")]
    public async Task<IActionResult> UploadProfilePicture(IFormFile file)
    {
        var userId = GetCurrentUserId();
        if (userId == null) return Unauthorized();

        if (file == null || file.Length == 0)
            return BadRequest("Nije odabrana slika");

        var fileRequest = new FileUploadRequest
        {
            FileStream = file.OpenReadStream(),
            FileName = file.FileName,
            ContentType = file.ContentType,
            FileSize = file.Length
        };

        var imageUrl = await _profileService.UploadProfilePictureAsync(userId.Value, fileRequest);
        if (imageUrl == null)
            return BadRequest("Greska prilikom azuriranja slike");

        return Ok(new { profileImageUrl = imageUrl });
    }

    [HttpDelete("picture")]
    public async Task<IActionResult> DeleteProfilePicture()
    {
        var userId = GetCurrentUserId();
        if (userId == null) return Unauthorized();

        var success = await _profileService.DeleteProfilePictureAsync(userId.Value);
        if (!success)
            return BadRequest("Greska prilikom brisanja slike");

        return Ok();
    }

    [HttpGet]
    public async Task<IActionResult> GetProfile()
    {
        var userId = GetCurrentUserId();
        if (userId == null) return Unauthorized();

        var profile = await _profileService.GetProfileAsync(userId.Value);
        if (profile == null)
            return NotFound();

        return Ok(profile);
    }
}
