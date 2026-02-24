namespace Stronghold.Application.IServices;

public interface ICurrentUserService
{
    int? UserId { get; }
    string? Username { get; }
    bool IsAuthenticated { get; }
    bool IsInRole(string role);
}
