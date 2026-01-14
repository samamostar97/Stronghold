using Stronghold.Application.Common;
using Stronghold.Application.DTOs.AdminMembershipsDTO;

namespace Stronghold.Application.IServices;

public interface IAdminMembershipService
{
    // Membership Packages (catalog)
    Task<List<MembershipPackageDTO>> GetAllPackagesAsync();
    Task<MembershipPackageDTO?> GetPackageByIdAsync(int packageId);
    Task<MembershipPackageDTO> CreatePackageAsync(CreateMembershipPackageRequest request);
    Task<MembershipPackageDTO?> UpdatePackageAsync(int packageId, UpdateMembershipPackageRequest request);
    Task<bool> DeletePackageAsync(int packageId);

    // Users with memberships
    Task<PagedResult<MembershipUserRowDTO>> GetUsersAsync(string? search, PaginationRequest pagination);
    Task<UserMembershipDTO?> GetUserMembershipAsync(int userId);

    // Payment history
    Task<PagedResult<MembershipPaymentRowDTO>> GetPaymentsAsync(int userId, PaginationRequest pagination);

    // Assign/renew membership
    Task<bool> AssignMembershipAsync(int userId, AddMembershipPaymentRequest request);
}
