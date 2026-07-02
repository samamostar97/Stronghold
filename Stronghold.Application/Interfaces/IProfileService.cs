using Stronghold.Application.DTOs.Profile;
using Stronghold.Application.DTOs.Users;

namespace Stronghold.Application.Interfaces;

// Operacije nad podacima trenutno prijavljenog korisnika - id uvijek dolazi iz JWT tokena.
public interface IProfileService
{
    Task<UserResponse> GetAsync();
    Task<UserResponse> UpdateAsync(UpdateProfileRequest request);
    Task ChangePasswordAsync(ChangePasswordRequest request);
    Task<(byte[] Data, string ContentType)> GetImageAsync();
}
