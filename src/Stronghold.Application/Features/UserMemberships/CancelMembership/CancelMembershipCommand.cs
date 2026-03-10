using MediatR;
using Stronghold.Application.Common;

namespace Stronghold.Application.Features.UserMemberships.CancelMembership;

[AuthorizeRole("Admin")]
public class CancelMembershipCommand : IRequest<Unit>
{
    public int UserId { get; set; }
}
