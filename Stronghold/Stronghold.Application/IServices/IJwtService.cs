using Stronghold.Application.DTOs.Request;
using Stronghold.Application.DTOs.Response;

namespace Stronghold.Application.IServices;

public interface IJwtService
{
    Task<AuthResponse> LoginAsync(LoginRequest request);
    Task<AuthResponse?> RegisterAsync(RegisterRequest request);
    Task ChangePasswordAsync(int userId, ChangePasswordRequest request);
    Task ForgotPasswordAsync(ForgotPasswordRequest request);
    Task ResetPasswordAsync(ResetPasswordRequest request);
}
