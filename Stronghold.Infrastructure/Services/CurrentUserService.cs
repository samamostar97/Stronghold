using System.Security.Claims;
using Microsoft.AspNetCore.Http;
using Stronghold.Application.Exceptions;
using Stronghold.Application.Interfaces;
using Stronghold.Core;

namespace Stronghold.Infrastructure.Services;

public class CurrentUserService : ICurrentUserService
{
    private readonly IHttpContextAccessor _httpContextAccessor;

    public CurrentUserService(IHttpContextAccessor httpContextAccessor)
    {
        _httpContextAccessor = httpContextAccessor;
    }

    public int UserId
    {
        get
        {
            var value = _httpContextAccessor.HttpContext?.User.FindFirstValue(ClaimTypes.NameIdentifier);
            if (!int.TryParse(value, out var userId))
            {
                throw new UnauthorizedException("Korisnik nije prijavljen.");
            }
            return userId;
        }
    }

    public bool IsAdmin => _httpContextAccessor.HttpContext?.User.IsInRole(Roles.Admin) ?? false;
}
