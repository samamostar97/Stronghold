using MediatR;

namespace Stronghold.Application.Features.Auth.Logout;

public class LogoutCommand : IRequest<Unit>
{
    public string RefreshToken { get; set; } = string.Empty;
}
