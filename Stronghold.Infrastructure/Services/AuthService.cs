using System.IdentityModel.Tokens.Jwt;
using System.Security.Claims;
using System.Security.Cryptography;
using System.Text;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Configuration;
using Microsoft.IdentityModel.Tokens;
using Stronghold.Application.Common;
using Stronghold.Application.DTOs.Auth;
using Stronghold.Application.DTOs.Messaging;
using Stronghold.Application.Exceptions;
using Stronghold.Application.Interfaces;
using Stronghold.Core.Entities;
using Stronghold.Core.Enums;
using Stronghold.Infrastructure.Data;
using Stronghold.Infrastructure.Security;

namespace Stronghold.Infrastructure.Services;

public class AuthService : IAuthService
{
    private readonly StrongholdDbContext _db;
    private readonly ICurrentUserService _currentUser;
    private readonly IEmailPublisher _emailPublisher;
    private readonly string _jwtKey;

    public AuthService(
        StrongholdDbContext db,
        ICurrentUserService currentUser,
        IEmailPublisher emailPublisher,
        IConfiguration configuration)
    {
        _db = db;
        _currentUser = currentUser;
        _emailPublisher = emailPublisher;
        // environment varijabla se cita jednom u konstruktoru
        _jwtKey = configuration["JWT_KEY"]
            ?? throw new InvalidOperationException("Environment varijabla JWT_KEY nije postavljena.");
    }

    public async Task<AuthResponse> LoginAsync(LoginRequest request)
    {
        var user = await _db.Users.FirstOrDefaultAsync(u =>
            u.Username == request.UsernameOrEmail || u.Email == request.UsernameOrEmail);

        if (user == null || !PasswordHasher.Verify(request.Password, user.PasswordSalt, user.PasswordHash))
        {
            throw new UnauthorizedException("Pogrešno korisničko ime/e-mail ili lozinka.");
        }

        return await CreateAuthResponseAsync(user);
    }

    public async Task<AuthResponse> RegisterAsync(RegisterRequest request)
    {
        if (await _db.Users.AnyAsync(u => u.Username == request.Username))
        {
            throw new BusinessException("Korisničko ime je već zauzeto. Odaberite drugo.");
        }
        if (await _db.Users.AnyAsync(u => u.Email == request.Email))
        {
            throw new BusinessException("Nalog sa ovom e-mail adresom već postoji.");
        }

        var salt = PasswordHasher.GenerateSalt();
        var user = new User
        {
            FirstName = request.FirstName,
            LastName = request.LastName,
            Username = request.Username,
            Email = request.Email,
            Phone = request.Phone,
            PasswordSalt = salt,
            PasswordHash = PasswordHasher.Hash(request.Password, salt),
            // rola se nikad ne prima od klijenta - registracijom se uvijek postaje clan
            Role = UserRole.GymMember,
            CreatedAt = DateTime.UtcNow
        };
        _db.Users.Add(user);

        return await CreateAuthResponseAsync(user);
    }

    public async Task<AuthResponse> RefreshAsync(RefreshRequest request)
    {
        var stored = await _db.RefreshTokens
            .Include(t => t.User)
            .FirstOrDefaultAsync(t => t.Token == request.RefreshToken);

        if (stored == null || stored.RevokedAt != null || stored.ExpiresAt <= DateTime.UtcNow)
        {
            throw new UnauthorizedException("Sesija je istekla. Prijavite se ponovo.");
        }

        // rotacija: stari token se revoka, izdaje se novi
        stored.RevokedAt = DateTime.UtcNow;
        return await CreateAuthResponseAsync(stored.User);
    }

    public async Task LogoutAsync(RefreshRequest request)
    {
        var stored = await _db.RefreshTokens
            .FirstOrDefaultAsync(t => t.Token == request.RefreshToken && t.UserId == _currentUser.UserId);

        if (stored != null && stored.RevokedAt == null)
        {
            stored.RevokedAt = DateTime.UtcNow;
        }
        await _db.SaveChangesAsync();
    }

    public async Task ForgotPasswordAsync(ForgotPasswordRequest request)
    {
        var user = await _db.Users.FirstOrDefaultAsync(u => u.Email == request.Email);
        // odgovor je uvijek isti - ne otkriva se da li nalog postoji
        if (user == null)
        {
            return;
        }

        // 6-cifreni kod iz kriptografskog generatora; u bazi samo hash + istek
        var code = (RandomNumberGenerator.GetInt32(0, 1_000_000)).ToString("D6");
        var salt = PasswordHasher.GenerateSalt();
        _db.PasswordResetTokens.Add(new PasswordResetToken
        {
            UserId = user.Id,
            CodeSalt = salt,
            CodeHash = PasswordHasher.Hash(code, salt),
            CreatedAt = DateTime.UtcNow,
            ExpiresAt = DateTime.UtcNow.AddMinutes(15)
        });
        await _db.SaveChangesAsync();

        _emailPublisher.Publish(new EmailMessage
        {
            To = user.Email,
            Subject = "Stronghold - kod za reset lozinke",
            Body = $"Poštovani {user.FirstName},\n\nvaš kod za reset lozinke je: {code}\n" +
                   "Kod vrijedi 15 minuta. Ako niste tražili reset, ignorišite ovu poruku.\n\nVaš Stronghold"
        });
    }

    public async Task ResetPasswordAsync(ResetPasswordRequest request)
    {
        var user = await _db.Users.FirstOrDefaultAsync(u => u.Email == request.Email)
            ?? throw new BusinessException("Kod nije ispravan ili je istekao.");

        var now = DateTime.UtcNow;
        var tokens = await _db.PasswordResetTokens
            .Where(t => t.UserId == user.Id && t.UsedAt == null && t.ExpiresAt > now)
            .OrderByDescending(t => t.CreatedAt)
            .ToListAsync();

        var token = tokens.FirstOrDefault(t =>
            PasswordHasher.Verify(request.Code, t.CodeSalt, t.CodeHash))
            ?? throw new BusinessException("Kod nije ispravan ili je istekao.");

        token.UsedAt = now;
        user.PasswordSalt = PasswordHasher.GenerateSalt();
        user.PasswordHash = PasswordHasher.Hash(request.NewPassword, user.PasswordSalt);
        await _db.SaveChangesAsync();
    }

    private async Task<AuthResponse> CreateAuthResponseAsync(User user)
    {
        var refreshToken = new RefreshToken
        {
            User = user,
            Token = Convert.ToBase64String(RandomNumberGenerator.GetBytes(64)),
            CreatedAt = DateTime.UtcNow,
            ExpiresAt = DateTime.UtcNow.AddDays(AuthConstants.RefreshTokenDays)
        };
        _db.RefreshTokens.Add(refreshToken);
        await _db.SaveChangesAsync();

        return new AuthResponse
        {
            AccessToken = GenerateAccessToken(user),
            RefreshToken = refreshToken.Token,
            UserId = user.Id,
            Username = user.Username,
            FirstName = user.FirstName,
            LastName = user.LastName,
            Role = user.Role.ToString()
        };
    }

    private string GenerateAccessToken(User user)
    {
        var claims = new[]
        {
            new Claim(ClaimTypes.NameIdentifier, user.Id.ToString()),
            new Claim(ClaimTypes.Name, user.Username),
            new Claim(ClaimTypes.Role, user.Role.ToString())
        };

        var credentials = new SigningCredentials(
            new SymmetricSecurityKey(Encoding.UTF8.GetBytes(_jwtKey)),
            SecurityAlgorithms.HmacSha256);

        var token = new JwtSecurityToken(
            issuer: AuthConstants.Issuer,
            audience: AuthConstants.Audience,
            claims: claims,
            expires: DateTime.UtcNow.AddMinutes(AuthConstants.AccessTokenMinutes),
            signingCredentials: credentials);

        return new JwtSecurityTokenHandler().WriteToken(token);
    }
}
