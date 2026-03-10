using MediatR;
using Stronghold.Application.Common;

namespace Stronghold.Application.Features.Users.UpdateProfileImage;

[AuthorizeRole("User")]
public class UpdateProfileImageCommand : IRequest<UserResponse>
{
    public Stream FileStream { get; set; } = null!;
    public string FileName { get; set; } = string.Empty;
}
