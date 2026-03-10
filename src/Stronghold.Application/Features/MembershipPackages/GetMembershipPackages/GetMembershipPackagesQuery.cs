using MediatR;
using Stronghold.Application.Common;

namespace Stronghold.Application.Features.MembershipPackages.GetMembershipPackages;

public class GetMembershipPackagesQuery : BaseQueryFilter, IRequest<PagedResult<MembershipPackageResponse>>
{
}
