using MediatR;
using Stronghold.Application.Common;

namespace Stronghold.Application.Features.Users.UpdateMyProfile;

[AuthorizeRole("User")]
public class UpdateMyProfileCommand : IRequest<UserResponse>
{
    public string FirstName { get; set; } = string.Empty;
    public string LastName { get; set; } = string.Empty;
    public string? Phone { get; set; }
    public string? Address { get; set; }
}
