using System.IdentityModel.Tokens.Jwt;
using System.Security.Claims;
using System.Text;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Configuration;
using Microsoft.IdentityModel.Tokens;
using Stronghold.Application.DTOs.Request;
using Stronghold.Application.DTOs.Response;
using Stronghold.Application.IServices;
using Stronghold.Core.Entities;
using Stronghold.Core.Enums;
using Stronghold.Application.Exceptions;
using Stronghold.Infrastructure.Data;

namespace Stronghold.Infrastructure.Services;

public class AuthService : IAuthService
{
    private readonly StrongholdDbContext _context;
    private readonly IEmailService _emailService;
    private readonly string _jwtSecret;
    private readonly string _jwtIssuer;
    private readonly string _jwtAudience;
    public AuthService(StrongholdDbContext context, IEmailService emailService)
    {
        _context = context;
        _emailService = emailService;
        _jwtSecret = Environment.GetEnvironmentVariable("JWT_SECRET")
            ?? throw new InvalidOperationException("JWT_SECRET nije konfigurisan");
        _jwtIssuer = Environment.GetEnvironmentVariable("JWT_ISSUER")
            ?? throw new InvalidOperationException("JWT_ISSUER nije konfigurisan");
        _jwtAudience = Environment.GetEnvironmentVariable("JWT_AUDIENCE")
            ?? throw new InvalidOperationException("JWT_AUDIENCE nije konfigurisan");
    }
    public Task<bool> IsAdminAsync(ClaimsPrincipal user)
    {
        if (user == null)
            return Task.FromResult(false);

        if (!user.Identity?.IsAuthenticated ?? true)
            return Task.FromResult(false);

        var isAdmin = user.IsInRole("Admin");

        return Task.FromResult(isAdmin);
    }
    public async Task<AuthResponse> LoginAsync(LoginRequest request)
    {
        var user = await _context.Users
            .FirstOrDefaultAsync(u => u.Username.ToLower() == request.Username.ToLower());

        if (user == null || !BCrypt.Net.BCrypt.Verify(request.Password, user.PasswordHash))
            throw new UnauthorizedAccessException("Neispravan username ili password");

        return await GenerateAuthResponseAsync(user);
    }

    public async Task<AuthResponse?> RegisterAsync(RegisterRequest request)
    {
        var usernameExists = await _context.Users.AnyAsync(x => x.Username.ToLower() == request.Username.ToLower());
        if (usernameExists) throw new ConflictException("Ovaj username je zauzet");
        var emailExists = await _context.Users.AnyAsync(x => x.Email.ToLower() == request.Email.ToLower());
        if (emailExists) throw new ConflictException("Ovaj email je zauzet");
        var numberExists = await _context.Users.AnyAsync(x => x.PhoneNumber == request.PhoneNumber);
        if (numberExists) throw new ConflictException("Ovaj broj je zauzet");
        

        var user = new User
        {
            FirstName = request.FirstName,
            LastName = request.LastName,
            Username = request.Username,
            Email = request.Email,
            PhoneNumber = request.PhoneNumber,
            Role = Role.GymMember,
            PasswordHash = BCrypt.Net.BCrypt.HashPassword(request.Password)
        };

        _context.Users.Add(user);
        await _context.SaveChangesAsync();

        return await GenerateAuthResponseAsync(user);
    }

    private async Task<AuthResponse> GenerateAuthResponseAsync(User user)
    {
        var token = GenerateJwtToken(user);

        var hasActiveMembership = await _context.Memberships
            .AnyAsync(m => m.UserId == user.Id && m.EndDate >= DateTime.UtcNow);

        return new AuthResponse
        {
            UserId = user.Id,
            FirstName = user.FirstName,
            LastName = user.LastName,
            Username = user.Username,
            Email = user.Email,
            ProfileImageUrl = user.ProfileImageUrl,
            Token = token,
            Role = user.Role.ToString(),
            HasActiveMembership = hasActiveMembership
        };
    }

    public async Task ChangePasswordAsync(int userId, ChangePasswordRequest request)
    {
        var user = await _context.Users.FindAsync(userId);
        if (user == null)
            throw new KeyNotFoundException("Korisnik nije pronađen");

        if (!BCrypt.Net.BCrypt.Verify(request.CurrentPassword, user.PasswordHash))
            throw new UnauthorizedAccessException("Trenutna lozinka nije ispravna");

        user.PasswordHash = BCrypt.Net.BCrypt.HashPassword(request.NewPassword);
        await _context.SaveChangesAsync();
    }

    public async Task ForgotPasswordAsync(ForgotPasswordRequest request)
    {
        var user = await _context.Users
            .FirstOrDefaultAsync(u => u.Email.ToLower() == request.Email.ToLower());

        if (user == null)
            throw new KeyNotFoundException("Korisnik sa ovim emailom ne postoji");

        var existingTokens = _context.PasswordResetTokens
            .Where(t => t.UserId == user.Id);
        _context.PasswordResetTokens.RemoveRange(existingTokens);

        var code = Random.Shared.Next(100000, 999999).ToString();

        var resetToken = new PasswordResetToken
        {
            UserId = user.Id,
            Token = code,
            ExpiresAt = DateTime.UtcNow.AddMinutes(15)
        };

        _context.PasswordResetTokens.Add(resetToken);
        await _context.SaveChangesAsync();

        await _emailService.SendEmailAsync(
            user.Email,
            "Stronghold - Reset lozinke",
            $"Vaš kod za reset lozinke je: {code}\n\nKod ističe za 15 minuta.");
    }

    public async Task ResetPasswordAsync(ResetPasswordRequest request)
    {
        var user = await _context.Users
            .FirstOrDefaultAsync(u => u.Email.ToLower() == request.Email.ToLower());

        if (user == null)
            throw new KeyNotFoundException("Korisnik nije pronađen");

        var token = await _context.PasswordResetTokens
            .FirstOrDefaultAsync(t => t.UserId == user.Id
                && t.Token == request.Code
                && t.ExpiresAt > DateTime.UtcNow);

        if (token == null)
            throw new UnauthorizedAccessException("Kod je nevažeći ili je istekao");

        user.PasswordHash = BCrypt.Net.BCrypt.HashPassword(request.NewPassword);
        _context.PasswordResetTokens.Remove(token);
        await _context.SaveChangesAsync();
    }

    private string GenerateJwtToken(User user)
    {

        var key = new SymmetricSecurityKey(Encoding.UTF8.GetBytes(_jwtSecret));
        var credentials = new SigningCredentials(key, SecurityAlgorithms.HmacSha256);

        var claims = new[]
        {
            new Claim(ClaimTypes.NameIdentifier, user.Id.ToString()),
            new Claim(ClaimTypes.Name, user.Username),
            new Claim(ClaimTypes.Email, user.Email),
            new Claim(ClaimTypes.Role, user.Role.ToString())
        };

        var token = new JwtSecurityToken(
            issuer: _jwtIssuer,
            audience: _jwtAudience,
            claims: claims,
            expires: DateTime.UtcNow.AddHours(24),
            signingCredentials: credentials
        );

        return new JwtSecurityTokenHandler().WriteToken(token);
    }
}
