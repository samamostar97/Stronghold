using MediatR;

namespace Stronghold.Application.Features.Auth.AdminLogin;

public class AdminLoginCommand : IRequest<AuthResponse>
{
    public string Username { get; set; } = string.Empty;
    public string Password { get; set; } = string.Empty;
}
