using MediatR;
using Stronghold.Application.Features.Users;
using Stronghold.Application.Interfaces;
using Stronghold.Domain.Entities;
using Stronghold.Domain.Enums;
using Stronghold.Domain.Exceptions;
using Stronghold.Messaging;
using Stronghold.Messaging.Events;

namespace Stronghold.Application.Features.Auth.Register;

public class RegisterCommandHandler : IRequestHandler<RegisterCommand, AuthResponse>
{
    private readonly IUserRepository _userRepository;
    private readonly IRefreshTokenRepository _refreshTokenRepository;
    private readonly IJwtService _jwtService;
    private readonly IPasswordHasher _passwordHasher;
    private readonly IMessagePublisher _messagePublisher;

    public RegisterCommandHandler(
        IUserRepository userRepository,
        IRefreshTokenRepository refreshTokenRepository,
        IJwtService jwtService,
        IPasswordHasher passwordHasher,
        IMessagePublisher messagePublisher)
    {
        _userRepository = userRepository;
        _refreshTokenRepository = refreshTokenRepository;
        _jwtService = jwtService;
        _passwordHasher = passwordHasher;
        _messagePublisher = messagePublisher;
    }

    public async Task<AuthResponse> Handle(RegisterCommand request, CancellationToken cancellationToken)
    {
        var fieldErrors = new Dictionary<string, string>();

        var existingByUsername = await _userRepository.GetByUsernameAsync(request.Username);
        if (existingByUsername != null)
            fieldErrors["username"] = "Korisničko ime je već zauzeto.";

        var existingByEmail = await _userRepository.GetByEmailAsync(request.Email);
        if (existingByEmail != null)
            fieldErrors["email"] = "Email je već registrovan.";

        if (!string.IsNullOrWhiteSpace(request.Phone))
        {
            var existingByPhone = await _userRepository.GetByPhoneAsync(request.Phone);
            if (existingByPhone != null)
                fieldErrors["phone"] = "Broj telefona je već registrovan.";
        }

        if (fieldErrors.Count > 0)
            throw new ConflictException(fieldErrors);

        var user = new User
        {
            Username = request.Username,
            Email = request.Email,
            FirstName = request.FirstName,
            LastName = request.LastName,
            Phone = request.Phone,
            Address = request.Address,
            PasswordHash = _passwordHasher.Hash(request.Password),
            Role = Role.User
        };

        await _userRepository.AddAsync(user);
        await _userRepository.SaveChangesAsync();

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

        await _messagePublisher.PublishAsync(QueueNames.UserRegistered, new UserRegisteredEvent
        {
            Email = user.Email,
            FirstName = user.FirstName
        });

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
