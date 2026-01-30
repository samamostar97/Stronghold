using Stronghold.Application.Common;
using Stronghold.Application.DTOs.UserProfile;

namespace Stronghold.Application.IServices;

public interface IUserProfileService
{
    Task<UserProfileDTO?> GetProfileAsync(int userId);
    Task<bool> UpdateProfilePictureAsync(int userId, string? imageUrl);
    Task<string?> UploadProfilePictureAsync(int userId, FileUploadRequest fileRequest);
    Task<bool> DeleteProfilePictureAsync(int userId);
}
