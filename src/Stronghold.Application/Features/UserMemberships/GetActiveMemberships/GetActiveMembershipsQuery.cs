using MediatR;
using Stronghold.Application.Common;

namespace Stronghold.Application.Features.UserMemberships.GetActiveMemberships;

[AuthorizeRole("Admin")]
public class GetActiveMembershipsQuery : BaseQueryFilter, IRequest<PagedResult<UserMembershipResponse>>
{
}
