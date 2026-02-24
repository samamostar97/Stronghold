using Stronghold.Application.Common;
using Stronghold.Application.Features.MembershipPackages.DTOs;
using Stronghold.Core.Entities;

namespace Stronghold.Application.IRepositories;

public interface IMembershipPackageRepository
{
    Task<PagedResult<MembershipPackage>> GetPagedAsync(
        MembershipPackageFilter filter,
        CancellationToken cancellationToken = default);
    Task<MembershipPackage?> GetByIdAsync(int id, CancellationToken cancellationToken = default);
    Task<bool> ExistsByNameAsync(string packageName, int? excludeId = null, CancellationToken cancellationToken = default);
    Task<bool> HasActiveMembershipsAsync(int membershipPackageId, CancellationToken cancellationToken = default);
    Task AddAsync(MembershipPackage entity, CancellationToken cancellationToken = default);
    Task UpdateAsync(MembershipPackage entity, CancellationToken cancellationToken = default);
    Task DeleteAsync(MembershipPackage entity, CancellationToken cancellationToken = default);
}
