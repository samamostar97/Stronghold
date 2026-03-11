using MediatR;
using Stronghold.Application.Common;

namespace Stronghold.Application.Features.Users.UpdateUserProfileImage;

[AuthorizeRole("Admin")]
public class UpdateUserProfileImageCommand : IRequest<UserResponse>
{
    public int Id { get; set; }
    public Stream FileStream { get; set; } = null!;
    public string FileName { get; set; } = string.Empty;
}
