using Microsoft.EntityFrameworkCore;
using Stronghold.Application.DTOs.UserProfile;
using Stronghold.Application.IServices;
using Stronghold.Infrastructure.Data;

namespace Stronghold.Infrastructure.Services;

public class UserProfileService : IUserProfileService
{
    private readonly StrongholdDbContext _context;

    public UserProfileService(StrongholdDbContext context)
    {
        _context = context;
    }

    public async Task<UserProfileDTO?> GetProfileAsync(int userId)
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
}
