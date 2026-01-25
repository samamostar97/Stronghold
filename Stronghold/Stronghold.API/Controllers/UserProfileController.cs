using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Stronghold.Application.IServices;

namespace Stronghold.API.Controllers;

[ApiController]
[Route("api/user/profile")]
[Authorize]
public class UserProfileController : UserControllerBase
{
    private readonly IUserProfileService _profileService;
    private readonly IWebHostEnvironment _environment;

    public UserProfileController(IUserProfileService profileService, IWebHostEnvironment environment)
    {
        _profileService = profileService;
        _environment = environment;
    }

    [HttpPost("picture")]
    public async Task<IActionResult> UploadProfilePicture(IFormFile file)
    {
        var userId = GetCurrentUserId();
        if (userId == null) return Unauthorized();

        if (file == null || file.Length == 0)
            return BadRequest("Nije odabrana slika");

        // Validate file type
        var allowedExtensions = new[] { ".jpg", ".jpeg", ".png", ".gif" };
        var extension = Path.GetExtension(file.FileName).ToLowerInvariant();
        if (!allowedExtensions.Contains(extension))
            return BadRequest("Dozvoljeni formati: JPG, PNG, GIF");

        // Validate file size (max 5MB)
        if (file.Length > 5 * 1024 * 1024)
            return BadRequest("Maksimalna velicina slike je 5MB");

        // Create uploads directory if it doesn't exist
        var uploadsFolder = Path.Combine(_environment.WebRootPath ?? Path.Combine(_environment.ContentRootPath, "wwwroot"), "uploads", "profile-pictures");
        Directory.CreateDirectory(uploadsFolder);

        // Generate unique filename
        var fileName = $"{userId.Value}_{Guid.NewGuid()}{extension}";
        var filePath = Path.Combine(uploadsFolder, fileName);

        // Save the file
        using (var stream = new FileStream(filePath, FileMode.Create))
        {
            await file.CopyToAsync(stream);
        }

        // Generate the URL
        var imageUrl = $"/uploads/profile-pictures/{fileName}";

        // Update user's profile image URL in database
        var success = await _profileService.UpdateProfilePictureAsync(userId.Value, imageUrl);
        if (!success)
        {
            // Clean up the uploaded file if database update fails
            if (System.IO.File.Exists(filePath))
                System.IO.File.Delete(filePath);
            return BadRequest("Greska prilikom azuriranja slike");
        }

        return Ok(new { profileImageUrl = imageUrl });
    }

    [HttpDelete("picture")]
    public async Task<IActionResult> DeleteProfilePicture()
    {
        var userId = GetCurrentUserId();
        if (userId == null) return Unauthorized();

        var success = await _profileService.UpdateProfilePictureAsync(userId.Value, null);
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
