using MediatR;
using Stronghold.Application.Common;

namespace Stronghold.Application.Features.MembershipPackages.CreateMembershipPackage;

[AuthorizeRole("Admin")]
public class CreateMembershipPackageCommand : IRequest<MembershipPackageResponse>
{
    public string Name { get; set; } = string.Empty;
    public string? Description { get; set; }
    public decimal Price { get; set; }
}
