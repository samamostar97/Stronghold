using Stronghold.Application.DTOs.Request;
using Stronghold.Application.DTOs.Response;
using System.Security.Claims;

namespace Stronghold.Application.IServices;

public interface IAuthService
{
    Task<AuthResponse> LoginAsync(LoginRequest request);
    Task<AuthResponse?> RegisterAsync(RegisterRequest request);
    Task<bool> IsAdminAsync(ClaimsPrincipal user);
    Task ChangePasswordAsync(int userId, ChangePasswordRequest request);
    Task ForgotPasswordAsync(ForgotPasswordRequest request);
    Task ResetPasswordAsync(ResetPasswordRequest request);
}
