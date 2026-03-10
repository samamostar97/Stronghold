using MediatR;
using Stronghold.Application.Common;

namespace Stronghold.Application.Features.Users.CreateUser;

[AuthorizeRole("Admin")]
public class CreateUserCommand : IRequest<UserResponse>
{
    public string Username { get; set; } = string.Empty;
    public string Email { get; set; } = string.Empty;
    public string FirstName { get; set; } = string.Empty;
    public string LastName { get; set; } = string.Empty;
    public string? Phone { get; set; }
    public string? Address { get; set; }
    public string Password { get; set; } = string.Empty;
}
