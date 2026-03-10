using Stronghold.Domain.Entities;

namespace Stronghold.Application.Features.MembershipPackages;

public static class MembershipPackageMappings
{
    public static MembershipPackageResponse ToResponse(MembershipPackage package) => new()
    {
        Id = package.Id,
        Name = package.Name,
        Description = package.Description,
        Price = package.Price,
        CreatedAt = package.CreatedAt
    };
}
