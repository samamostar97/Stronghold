using MediatR;
using Stronghold.Application.Common;

namespace Stronghold.Application.Features.UserMemberships.GetMembershipHistory;

[AuthorizeRole("Admin")]
public class GetMembershipHistoryQuery : BaseQueryFilter, IRequest<PagedResult<UserMembershipResponse>>
{
    public int UserId { get; set; }
}
