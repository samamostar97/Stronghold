using MediatR;
using Stronghold.Application.Common;

namespace Stronghold.Application.Features.MembershipPackages.DeleteMembershipPackage;

[AuthorizeRole("Admin")]
public class DeleteMembershipPackageCommand : IRequest<Unit>
{
    public int Id { get; set; }
}
