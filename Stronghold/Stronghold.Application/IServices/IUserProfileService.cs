using Stronghold.Application.DTOs.UserProfile;

namespace Stronghold.Application.IServices;

public interface IUserProfileService
{
    Task<UserProfileDTO?> GetProfileAsync(int userId);
    Task<bool> UpdateProfilePictureAsync(int userId, string? imageUrl);
}
