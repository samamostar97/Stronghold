using MediatR;
using Stronghold.Application.Common;

namespace Stronghold.Application.Features.UserMemberships.GetInactiveMemberships;

[AuthorizeRole("Admin")]
public class GetInactiveMembershipsQuery : BaseQueryFilter, IRequest<PagedResult<UserMembershipResponse>>
{
    public string? Status { get; set; } // "Expired" or "Cancelled"
}
