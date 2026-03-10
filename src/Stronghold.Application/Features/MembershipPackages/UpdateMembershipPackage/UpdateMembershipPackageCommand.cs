using MediatR;
using Stronghold.Application.Common;

namespace Stronghold.Application.Features.MembershipPackages.UpdateMembershipPackage;

[AuthorizeRole("Admin")]
public class UpdateMembershipPackageCommand : IRequest<MembershipPackageResponse>
{
    public int Id { get; set; }
    public string Name { get; set; } = string.Empty;
    public string? Description { get; set; }
    public decimal Price { get; set; }
}
