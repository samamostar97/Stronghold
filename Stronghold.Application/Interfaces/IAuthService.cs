using Stronghold.Application.DTOs.Auth;

namespace Stronghold.Application.Interfaces;

public interface IAuthService
{
    Task<AuthResponse> LoginAsync(LoginRequest request);
    Task<AuthResponse> RegisterAsync(RegisterRequest request);
    Task<AuthResponse> RefreshAsync(RefreshRequest request);
    Task LogoutAsync(RefreshRequest request);

    /// <summary>Salje 6-cifreni kod na e-mail; odgovor je isti postojao nalog ili ne.</summary>
    Task ForgotPasswordAsync(ForgotPasswordRequest request);

    Task ResetPasswordAsync(ResetPasswordRequest request);
}
