using MediatR;
using Stronghold.Application.Common;

namespace Stronghold.Application.Features.UserMemberships.AssignMembership;

[AuthorizeRole("Admin")]
public class AssignMembershipCommand : IRequest<UserMembershipResponse>
{
    public int UserId { get; set; }
    public int MembershipPackageId { get; set; }
}
