using MediatR;

namespace Stronghold.Application.Features.MembershipPackages.GetMembershipPackageById;

public class GetMembershipPackageByIdQuery : IRequest<MembershipPackageResponse>
{
    public int Id { get; set; }
}
