using MediatR;
using Stronghold.Application.Features.Users;
using Stronghold.Application.Interfaces;
using Stronghold.Domain.Exceptions;

namespace Stronghold.Application.Features.Auth.RefreshToken;

public class RefreshTokenCommandHandler : IRequestHandler<RefreshTokenCommand, AuthResponse>
{
    private readonly IUserRepository _userRepository;
    private readonly IRefreshTokenRepository _refreshTokenRepository;
    private readonly IJwtService _jwtService;

    public RefreshTokenCommandHandler(
        IUserRepository userRepository,
        IRefreshTokenRepository refreshTokenRepository,
        IJwtService jwtService)
    {
        _userRepository = userRepository;
        _refreshTokenRepository = refreshTokenRepository;
        _jwtService = jwtService;
    }

    public async Task<AuthResponse> Handle(RefreshTokenCommand request, CancellationToken cancellationToken)
    {
        var existingToken = await _refreshTokenRepository.GetByTokenAsync(request.RefreshToken);

        if (existingToken == null || existingToken.RevokedAt != null || existingToken.ExpiresAt <= DateTime.UtcNow)
            throw new UnauthorizedAccessException("Nevažeći ili istekli refresh token.");

        var user = await _userRepository.GetByIdAsync(existingToken.UserId);
        if (user == null)
            throw new NotFoundException("Korisnik", existingToken.UserId);

        existingToken.RevokedAt = DateTime.UtcNow;

        var accessToken = _jwtService.GenerateAccessToken(user);
        var newRefreshTokenValue = _jwtService.GenerateRefreshToken();

        var newRefreshToken = new Domain.Entities.RefreshToken
        {
            Token = newRefreshTokenValue,
            UserId = user.Id,
            ExpiresAt = DateTime.UtcNow.AddDays(
                int.TryParse(Environment.GetEnvironmentVariable("JWT_REFRESH_TOKEN_EXPIRY_DAYS"), out var days) ? days : 7)
        };

        await _refreshTokenRepository.AddAsync(newRefreshToken);
        await _refreshTokenRepository.SaveChangesAsync();

        return new AuthResponse
        {
            User = new UserResponse
            {
                Id = user.Id,
                FirstName = user.FirstName,
                LastName = user.LastName,
                Username = user.Username,
                Email = user.Email,
                Phone = user.Phone,
                Address = user.Address,
                ProfileImageUrl = user.ProfileImageUrl,
                Role = user.Role.ToString(),
                Level = user.Level,
                XP = user.XP,
                TotalGymMinutes = user.TotalGymMinutes
            },
            AccessToken = accessToken,
            RefreshToken = newRefreshTokenValue
        };
    }
}
