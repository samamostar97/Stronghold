using Stronghold.Domain.Entities;

namespace Stronghold.Application.Features.UserMemberships;

public static class UserMembershipMappings
{
    public static UserMembershipResponse ToResponse(UserMembership membership) => new()
    {
        Id = membership.Id,
        UserId = membership.UserId,
        UserFullName = !string.IsNullOrEmpty(membership.UserFullName) ? membership.UserFullName
            : membership.User != null ? $"{membership.User.FirstName} {membership.User.LastName}" : string.Empty,
        MembershipPackageId = membership.MembershipPackageId,
        MembershipPackageName = !string.IsNullOrEmpty(membership.PackageName) ? membership.PackageName
            : membership.MembershipPackage?.Name ?? string.Empty,
        MembershipPackagePrice = membership.PackagePrice > 0 ? membership.PackagePrice
            : membership.MembershipPackage?.Price ?? 0,
        StartDate = membership.StartDate,
        EndDate = membership.EndDate,
        IsActive = membership.IsActive,
        CreatedAt = membership.CreatedAt
    };
}
