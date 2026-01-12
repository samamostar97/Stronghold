using Stronghold.Application.DTOs.Auth;

namespace Stronghold.Application.IServices;

public interface IAuthService
{
    Task<AuthResponse?> LoginAsync(LoginRequest request);
    Task<AuthResponse?> RegisterAsync(RegisterRequest request);
}
