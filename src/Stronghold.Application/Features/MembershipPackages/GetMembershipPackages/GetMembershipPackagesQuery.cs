using MediatR;
using Stronghold.Application.Common;

namespace Stronghold.Application.Features.MembershipPackages.GetMembershipPackages;

[AuthorizeRole("Admin")]
[AuthorizeRole("User")]
public class GetMembershipPackagesQuery : BaseQueryFilter, IRequest<PagedResult<MembershipPackageResponse>>
{
}
