using MediatR;
using Stronghold.Application.Interfaces;

namespace Stronghold.Application.Features.Auth.Logout;

public class LogoutCommandHandler : IRequestHandler<LogoutCommand, Unit>
{
    private readonly IRefreshTokenRepository _refreshTokenRepository;

    public LogoutCommandHandler(IRefreshTokenRepository refreshTokenRepository)
    {
        _refreshTokenRepository = refreshTokenRepository;
    }

    public async Task<Unit> Handle(LogoutCommand request, CancellationToken cancellationToken)
    {
        var token = await _refreshTokenRepository.GetByTokenAsync(request.RefreshToken);

        if (token != null && token.RevokedAt == null)
        {
            token.RevokedAt = DateTime.UtcNow;
            await _refreshTokenRepository.SaveChangesAsync();
        }

        return Unit.Value;
    }
}
