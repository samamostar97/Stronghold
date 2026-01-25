using System.IdentityModel.Tokens.Jwt;
using System.Security.Claims;
using System.Text;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Configuration;
using Microsoft.IdentityModel.Tokens;
using Stronghold.Application.DTOs.Auth;
using Stronghold.Application.IServices;
using Stronghold.Core.Entities;
using Stronghold.Core.Enums;
using Stronghold.Core.Exceptions;
using Stronghold.Infrastructure.Data;

namespace Stronghold.Infrastructure.Services;

public class AuthService : IAuthService
{
    private readonly StrongholdDbContext _context;
    private readonly string _jwtSecret;
    private readonly string _jwtIssuer;
    private readonly string _jwtAudience;
    public AuthService(StrongholdDbContext context)
    {
        _context = context;
        _jwtSecret = Environment.GetEnvironmentVariable("JWT_SECRET")
            ?? throw new InvalidOperationException("JWT_SECRET nije konfigurisan");
        _jwtIssuer = Environment.GetEnvironmentVariable("JWT_ISSUER")
            ?? "Stronghold";
        _jwtAudience = Environment.GetEnvironmentVariable("JWT_AUDIENCE")
            ?? "StrongholdApp";
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
    public async Task<AuthResponse?> LoginAsync(LoginRequest request)
    {
        var user = await _context.Users
            .FirstOrDefaultAsync(u => u.Username == request.Username);

        if (user == null || !BCrypt.Net.BCrypt.Verify(request.Password, user.PasswordHash))
            return null;

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
            HasActiveMembership = hasActiveMembership
        };
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
