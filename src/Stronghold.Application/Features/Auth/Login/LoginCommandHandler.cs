using MediatR;
using Stronghold.Application.Features.Users;
using Stronghold.Application.Interfaces;
using Stronghold.Domain.Entities;
using Stronghold.Domain.Enums;

namespace Stronghold.Application.Features.Auth.Login;

public class LoginCommandHandler : IRequestHandler<LoginCommand, AuthResponse>
{
    private readonly IUserRepository _userRepository;
    private readonly IRefreshTokenRepository _refreshTokenRepository;
    private readonly IJwtService _jwtService;
    private readonly IPasswordHasher _passwordHasher;

    public LoginCommandHandler(
        IUserRepository userRepository,
        IRefreshTokenRepository refreshTokenRepository,
        IJwtService jwtService,
        IPasswordHasher passwordHasher)
    {
        _userRepository = userRepository;
        _refreshTokenRepository = refreshTokenRepository;
        _jwtService = jwtService;
        _passwordHasher = passwordHasher;
    }

    public async Task<AuthResponse> Handle(LoginCommand request, CancellationToken cancellationToken)
    {
        var user = await _userRepository.GetByUsernameAsync(request.Username);

        if (user == null || !_passwordHasher.Verify(request.Password, user.PasswordHash))
            throw new UnauthorizedAccessException("Pogrešno korisničko ime ili lozinka.");

        if (user.Role == Role.Admin)
            throw new UnauthorizedAccessException("Pristup nije dozvoljen za ovu platformu.");

        var accessToken = _jwtService.GenerateAccessToken(user);
        var refreshTokenValue = _jwtService.GenerateRefreshToken();

        var refreshToken = new Domain.Entities.RefreshToken
        {
            Token = refreshTokenValue,
            UserId = user.Id,
            ExpiresAt = DateTime.UtcNow.AddDays(
                int.TryParse(Environment.GetEnvironmentVariable("JWT_REFRESH_TOKEN_EXPIRY_DAYS"), out var days) ? days : 7)
        };

        await _refreshTokenRepository.AddAsync(refreshToken);
        await _refreshTokenRepository.SaveChangesAsync();

        return new AuthResponse
        {
            User = MapToUserResponse(user),
            AccessToken = accessToken,
            RefreshToken = refreshTokenValue
        };
    }

    private static UserResponse MapToUserResponse(User user) => new()
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
    };
}
