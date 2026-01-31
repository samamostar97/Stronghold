using Microsoft.EntityFrameworkCore;
using Stronghold.Application.Common;
using Stronghold.Application.DTOs.UserProfile;
using Stronghold.Application.IServices;
using Stronghold.Infrastructure.Data;

namespace Stronghold.Infrastructure.Services;

public class UserProfileService : IUserProfileService
{
    private readonly StrongholdDbContext _context;
    private readonly IFileStorageService _fileStorageService;

    public UserProfileService(StrongholdDbContext context, IFileStorageService fileStorageService)
    {
        _context = context;
        _fileStorageService = fileStorageService;
    }

    public async Task<UserProfileDTO> GetProfileAsync(int userId)
    {
        var user = await _context.Users
            .Where(u => u.Id == userId)
            .Select(u => new UserProfileDTO
            {
                Id = u.Id,
                FirstName = u.FirstName,
                LastName = u.LastName,
                Username = u.Username,
                Email = u.Email,
                PhoneNumber = u.PhoneNumber,
                ProfileImageUrl = u.ProfileImageUrl
            })
            .FirstOrDefaultAsync();

        if (user == null)
            throw new KeyNotFoundException("Korisnik nije pronađen");

        return user;
    }

    public async Task<bool> UpdateProfilePictureAsync(int userId, string? imageUrl)
    {
        var user = await _context.Users.FindAsync(userId);
        if (user == null)
            return false;

        user.ProfileImageUrl = imageUrl;
        await _context.SaveChangesAsync();
        return true;
    }

    public async Task<string> UploadProfilePictureAsync(int userId, FileUploadRequest fileRequest)
    {
        var user = await _context.Users.FindAsync(userId);
        if (user == null)
            throw new KeyNotFoundException("Korisnik nije pronađen");

        if (!string.IsNullOrEmpty(user.ProfileImageUrl))
        {
            await _fileStorageService.DeleteAsync(user.ProfileImageUrl);
        }

        var uploadResult = await _fileStorageService.UploadAsync(fileRequest, "profile-pictures", userId.ToString());

        if (!uploadResult.Success)
            throw new InvalidOperationException(uploadResult.ErrorMessage);

        user.ProfileImageUrl = uploadResult.FileUrl;
        await _context.SaveChangesAsync();

        return uploadResult.FileUrl!;
    }

    public async Task DeleteProfilePictureAsync(int userId)
    {
        var user = await _context.Users.FindAsync(userId);
        if (user == null)
            throw new KeyNotFoundException("Korisnik nije pronađen");

        if (string.IsNullOrEmpty(user.ProfileImageUrl))
            return;

        await _fileStorageService.DeleteAsync(user.ProfileImageUrl);

        user.ProfileImageUrl = null;
        await _context.SaveChangesAsync();
    }
}
