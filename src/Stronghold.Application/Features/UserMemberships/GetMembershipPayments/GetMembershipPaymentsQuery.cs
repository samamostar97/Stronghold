using MediatR;
using Stronghold.Application.Common;

namespace Stronghold.Application.Features.UserMemberships.GetMembershipPayments;

[AuthorizeRole("Admin")]
public class GetMembershipPaymentsQuery : BaseQueryFilter, IRequest<PagedResult<UserMembershipResponse>>
{
    public bool? IsActive { get; set; }
}
