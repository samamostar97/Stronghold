using Stronghold.Domain.Entities;

namespace Stronghold.Application.Features.UserMemberships;

public static class UserMembershipMappings
{
    public static UserMembershipResponse ToResponse(UserMembership membership) => new()
    {
        Id = membership.Id,
        UserId = membership.UserId,
        UserFullName = membership.User != null
            ? $"{membership.User.FirstName} {membership.User.LastName}"
            : string.Empty,
        MembershipPackageId = membership.MembershipPackageId,
        MembershipPackageName = membership.MembershipPackage?.Name ?? string.Empty,
        MembershipPackagePrice = membership.MembershipPackage?.Price ?? 0,
        StartDate = membership.StartDate,
        EndDate = membership.EndDate,
        IsActive = membership.IsActive,
        CreatedAt = membership.CreatedAt
    };
}
