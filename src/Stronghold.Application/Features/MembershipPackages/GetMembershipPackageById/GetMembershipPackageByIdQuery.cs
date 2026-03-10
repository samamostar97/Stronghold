using MediatR;
using Stronghold.Application.Common;

namespace Stronghold.Application.Features.MembershipPackages.GetMembershipPackageById;

[AuthorizeRole("Admin")]
[AuthorizeRole("User")]
public class GetMembershipPackageByIdQuery : IRequest<MembershipPackageResponse>
{
    public int Id { get; set; }
}
