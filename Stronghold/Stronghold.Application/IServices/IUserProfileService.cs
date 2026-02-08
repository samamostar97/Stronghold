using Stronghold.Application.Common;
using Stronghold.Application.DTOs.Response;

namespace Stronghold.Application.IServices;

public interface IUserProfileService
{
    // Profile info
    Task<UserProfileResponse> GetProfileAsync(int userId);
    Task<bool> UpdateProfilePictureAsync(int userId, string? imageUrl);
    Task<string> UploadProfilePictureAsync(int userId, FileUploadRequest fileRequest);
    Task DeleteProfilePictureAsync(int userId);

    // Membership payment history (from IUserMembershipService)
    Task<IEnumerable<MembershipPaymentResponse>> GetMembershipPaymentHistoryAsync(int userId);

    // Progress tracking (from IUserProgressService)
    Task<UserProgressResponse> GetProgressAsync(int userId);
    Task<List<LeaderboardEntryResponse>> GetLeaderboardAsync(int top = 5);
    Task<List<LeaderboardEntryResponse>> GetFullLeaderboardAsync();
}
