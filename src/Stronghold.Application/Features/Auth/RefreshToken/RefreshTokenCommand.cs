using MediatR;

namespace Stronghold.Application.Features.Auth.RefreshToken;

public class RefreshTokenCommand : IRequest<AuthResponse>
{
    public string RefreshToken { get; set; } = string.Empty;
}
