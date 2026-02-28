using Stronghold.Application.Common;
using Stronghold.Application.Features.Memberships.DTOs;
using Stronghold.Core.Entities;

namespace Stronghold.Application.IRepositories;

public interface IMembershipRepository
{
    Task<bool> UserExistsAsync(int userId, CancellationToken cancellationToken = default);
    Task<bool> MembershipPackageExistsAsync(int membershipPackageId, CancellationToken cancellationToken = default);
    Task<bool> HasActiveMembershipAsync(int userId, DateTime nowUtc, CancellationToken cancellationToken = default);
    Task<Membership?> GetActiveMembershipAsync(int userId, DateTime nowUtc, CancellationToken cancellationToken = default);
    Task<IReadOnlyList<MembershipPaymentHistory>> GetActivePaymentHistoriesAsync(
        int userId,
        DateTime nowUtc,
        CancellationToken cancellationToken = default);
    Task AddMembershipWithPaymentAsync(
        Membership membership,
        MembershipPaymentHistory paymentHistory,
        CancellationToken cancellationToken = default);
    Task UpdateMembershipAsync(Membership membership, CancellationToken cancellationToken = default);
    Task UpdatePaymentHistoryRangeAsync(
        IEnumerable<MembershipPaymentHistory> paymentHistories,
        CancellationToken cancellationToken = default);
    Task<PagedResult<MembershipPaymentHistory>> GetPaymentsPagedAsync(
        int userId,
        MembershipPaymentFilter filter,
        CancellationToken cancellationToken = default);
    Task<PagedResult<MembershipPaymentHistory>> GetAllPaymentsPagedAsync(
        AdminMembershipPaymentsFilter filter,
        CancellationToken cancellationToken = default);
    Task<IReadOnlyList<MembershipPaymentHistory>> GetPaymentsByUserAsync(
        int userId,
        CancellationToken cancellationToken = default);
    Task<PagedResult<Membership>> GetActiveMembersPagedAsync(
        ActiveMemberFilter filter,
        DateTime nowUtc,
        CancellationToken cancellationToken = default);
}
