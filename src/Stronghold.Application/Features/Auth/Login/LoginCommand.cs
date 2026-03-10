using MediatR;

namespace Stronghold.Application.Features.Auth.Login;

public class LoginCommand : IRequest<AuthResponse>
{
    public string Username { get; set; } = string.Empty;
    public string Password { get; set; } = string.Empty;
}
