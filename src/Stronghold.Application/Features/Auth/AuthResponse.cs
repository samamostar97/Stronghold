using Stronghold.Application.Features.Users;

namespace Stronghold.Application.Features.Auth;

public class AuthResponse
{
    public UserResponse User { get; set; } = null!;
    public string AccessToken { get; set; } = string.Empty;
    public string RefreshToken { get; set; } = string.Empty;
}
