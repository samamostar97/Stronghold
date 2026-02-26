using Microsoft.EntityFrameworkCore;
using Stronghold.Application.Common;
using Stronghold.Application.Features.Memberships.DTOs;
using Stronghold.Application.IRepositories;
using Stronghold.Core.Entities;
using Stronghold.Infrastructure.Data;

namespace Stronghold.Infrastructure.Repositories;

public class MembershipRepository : IMembershipRepository
{
    private readonly StrongholdDbContext _context;

    public MembershipRepository(StrongholdDbContext context)
    {
        _context = context;
    }

    public Task<bool> UserExistsAsync(int userId, CancellationToken cancellationToken = default)
    {
        return _context.Users
            .AnyAsync(x => x.Id == userId && !x.IsDeleted, cancellationToken);
    }

    public Task<bool> MembershipPackageExistsAsync(int membershipPackageId, CancellationToken cancellationToken = default)
    {
        return _context.MembershipPackages
            .AnyAsync(x => x.Id == membershipPackageId && !x.IsDeleted, cancellationToken);
    }

    public Task<bool> HasActiveMembershipAsync(int userId, DateTime nowUtc, CancellationToken cancellationToken = default)
    {
        return _context.Memberships
            .AnyAsync(x => !x.IsDeleted && x.UserId == userId && x.EndDate > nowUtc, cancellationToken);
    }

    public Task<Membership?> GetActiveMembershipAsync(int userId, DateTime nowUtc, CancellationToken cancellationToken = default)
    {
        return _context.Memberships
            .FirstOrDefaultAsync(x => !x.IsDeleted && x.UserId == userId && x.EndDate > nowUtc, cancellationToken);
    }

    public async Task<IReadOnlyList<MembershipPaymentHistory>> GetActivePaymentHistoriesAsync(
        int userId,
        DateTime nowUtc,
        CancellationToken cancellationToken = default)
    {
        return await _context.MembershipPaymentHistory
            .Where(x => !x.IsDeleted && x.UserId == userId && x.StartDate <= nowUtc && x.EndDate > nowUtc)
            .ToListAsync(cancellationToken);
    }

    public async Task AddMembershipWithPaymentAsync(
        Membership membership,
        MembershipPaymentHistory paymentHistory,
        CancellationToken cancellationToken = default)
    {
        await using var transaction = await _context.Database.BeginTransactionAsync(cancellationToken);
        try
        {
            await _context.Memberships.AddAsync(membership, cancellationToken);
            await _context.MembershipPaymentHistory.AddAsync(paymentHistory, cancellationToken);
            await _context.SaveChangesAsync(cancellationToken);
            await transaction.CommitAsync(cancellationToken);
        }
        catch
        {
            await transaction.RollbackAsync(cancellationToken);
            throw;
        }
    }

    public async Task UpdateMembershipAsync(Membership membership, CancellationToken cancellationToken = default)
    {
        _context.Memberships.Update(membership);
        await _context.SaveChangesAsync(cancellationToken);
    }

    public async Task UpdatePaymentHistoryRangeAsync(
        IEnumerable<MembershipPaymentHistory> paymentHistories,
        CancellationToken cancellationToken = default)
    {
        _context.MembershipPaymentHistory.UpdateRange(paymentHistories);
        await _context.SaveChangesAsync(cancellationToken);
    }

    public async Task<PagedResult<MembershipPaymentHistory>> GetPaymentsPagedAsync(
        int userId,
        MembershipPaymentFilter filter,
        CancellationToken cancellationToken = default)
    {
        filter ??= new MembershipPaymentFilter();

        var baseQuery = _context.MembershipPaymentHistory
            .AsNoTracking()
            .Include(x => x.MembershipPackage)
            .Where(x => !x.IsDeleted && x.UserId == userId)
            .AsQueryable();

        var query = filter.OrderBy?.Trim().ToLowerInvariant() switch
        {
            "date" => baseQuery.OrderBy(x => x.PaymentDate).ThenBy(x => x.Id),
            "datedesc" => baseQuery.OrderByDescending(x => x.PaymentDate).ThenByDescending(x => x.Id),
            "amount" => baseQuery.OrderBy(x => x.AmountPaid).ThenBy(x => x.Id),
            "amountdesc" => baseQuery.OrderByDescending(x => x.AmountPaid).ThenByDescending(x => x.Id),
            _ => baseQuery.OrderByDescending(x => x.PaymentDate).ThenByDescending(x => x.Id)
        };

        var totalCount = await query.CountAsync(cancellationToken);
        var items = await query
            .Skip((filter.PageNumber - 1) * filter.PageSize)
            .Take(filter.PageSize)
            .ToListAsync(cancellationToken);

        return new PagedResult<MembershipPaymentHistory>
        {
            Items = items,
            TotalCount = totalCount,
            PageNumber = filter.PageNumber
        };
    }

    public async Task<IReadOnlyList<MembershipPaymentHistory>> GetPaymentsByUserAsync(
        int userId,
        CancellationToken cancellationToken = default)
    {
        return await _context.MembershipPaymentHistory
            .AsNoTracking()
            .Include(x => x.MembershipPackage)
            .Where(x => !x.IsDeleted && x.UserId == userId)
            .OrderByDescending(x => x.PaymentDate)
            .ThenByDescending(x => x.Id)
            .ToListAsync(cancellationToken);
    }

    public async Task<PagedResult<Membership>> GetActiveMembersPagedAsync(
        ActiveMemberFilter filter,
        DateTime nowUtc,
        CancellationToken cancellationToken = default)
    {
        filter ??= new ActiveMemberFilter();

        var query = _context.Memberships
            .AsNoTracking()
            .Include(x => x.User)
            .Include(x => x.MembershipPackage)
            .Where(x => !x.IsDeleted &&
                        x.EndDate > nowUtc &&
                        !x.User.IsDeleted &&
                        !_context.GymVisits.Any(v =>
                            !v.IsDeleted && v.UserId == x.UserId && v.CheckOutTime == null))
            .AsQueryable();

        if (!string.IsNullOrWhiteSpace(filter.Name))
        {
            var name = filter.Name.Trim().ToLower();
            query = query.Where(x =>
                x.User.FirstName.ToLower().Contains(name) ||
                x.User.LastName.ToLower().Contains(name) ||
                x.User.Username.ToLower().Contains(name));
        }

        query = query
            .OrderBy(x => x.User.FirstName)
            .ThenBy(x => x.User.LastName)
            .ThenBy(x => x.Id);

        var totalCount = await query.CountAsync(cancellationToken);
        var items = await query
            .Skip((filter.PageNumber - 1) * filter.PageSize)
            .Take(filter.PageSize)
            .ToListAsync(cancellationToken);

        return new PagedResult<Membership>
        {
            Items = items,
            TotalCount = totalCount,
            PageNumber = filter.PageNumber
        };
    }
}
