using Stronghold.Application.DTOs.MembershipPackages;

namespace Stronghold.Application.Interfaces;

public interface IMembershipPackageService : ICrudService<MembershipPackageResponse, MembershipPackageSearch,
    MembershipPackageUpsertRequest, MembershipPackageUpsertRequest>
{
}
