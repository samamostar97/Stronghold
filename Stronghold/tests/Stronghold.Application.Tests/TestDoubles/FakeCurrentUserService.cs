using Stronghold.Application.IServices;

namespace Stronghold.Application.Tests.TestDoubles;

internal sealed class FakeCurrentUserService : ICurrentUserService
{
    private readonly HashSet<string> _roles;

    public FakeCurrentUserService(
        int? userId = null,
        string? username = null,
        bool isAuthenticated = false,
        params string[] roles)
    {
        UserId = userId;
        Username = username;
        IsAuthenticated = isAuthenticated;
        _roles = new HashSet<string>(roles ?? Array.Empty<string>(), StringComparer.OrdinalIgnoreCase);
    }

    public int? UserId { get; set; }
    public string? Username { get; set; }
    public bool IsAuthenticated { get; set; }

    public bool IsInRole(string role)
    {
        return _roles.Contains(role);
    }

    public void SetRoles(params string[] roles)
    {
        _roles.Clear();
        foreach (var role in roles)
        {
            _roles.Add(role);
        }
    }
}
