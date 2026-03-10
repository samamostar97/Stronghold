using MediatR;
using Stronghold.Application.Common;

namespace Stronghold.Application.Features.Users.UpdateUser;

[AuthorizeRole("Admin")]
public class UpdateUserCommand : IRequest<UserResponse>
{
    public int Id { get; set; }
    public string FirstName { get; set; } = string.Empty;
    public string LastName { get; set; } = string.Empty;
    public string Username { get; set; } = string.Empty;
    public string Email { get; set; } = string.Empty;
    public string? Phone { get; set; }
    public string? Address { get; set; }
}
