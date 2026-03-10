using System.Security.Claims;
using Stronghold.Application.Interfaces;

namespace Stronghold.API.Services;

public class CurrentUserService : ICurrentUserService
{
    private readonly IHttpContextAccessor _httpContextAccessor;

    public CurrentUserService(IHttpContextAccessor httpContextAccessor)
    {
        _httpContextAccessor = httpContextAccessor;
    }

    public int UserId => int.TryParse(
        _httpContextAccessor.HttpContext?.User?.FindFirstValue(ClaimTypes.NameIdentifier), out var id) ? id : 0;

    public string Role =>
        _httpContextAccessor.HttpContext?.User?.FindFirstValue(ClaimTypes.Role) ?? string.Empty;

    public bool IsAuthenticated =>
        _httpContextAccessor.HttpContext?.User?.Identity?.IsAuthenticated ?? false;
}
