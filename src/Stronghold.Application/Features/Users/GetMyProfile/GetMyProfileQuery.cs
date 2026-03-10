using MediatR;
using Stronghold.Application.Common;

namespace Stronghold.Application.Features.Users.GetMyProfile;

[AuthorizeRole("User")]
public class GetMyProfileQuery : IRequest<UserResponse>
{
}
