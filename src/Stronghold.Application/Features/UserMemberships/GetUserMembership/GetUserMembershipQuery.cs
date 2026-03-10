using MediatR;
using Stronghold.Application.Common;

namespace Stronghold.Application.Features.UserMemberships.GetUserMembership;

[AuthorizeRole("Admin")]
public class GetUserMembershipQuery : IRequest<UserMembershipResponse?>
{
    public int UserId { get; set; }
}
