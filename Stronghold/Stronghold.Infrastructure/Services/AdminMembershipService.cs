using Microsoft.EntityFrameworkCore;
using Stronghold.Application.Common;
using Stronghold.Application.DTOs.AdminMembershipsDTO;
using Stronghold.Application.IServices;
using Stronghold.Core.Entities;
using Stronghold.Infrastructure.Data;

namespace Stronghold.Infrastructure.Services;

public class AdminMembershipService : IAdminMembershipService
{
    private readonly StrongholdDbContext _context;

    public AdminMembershipService(StrongholdDbContext context)
    {
        _context = context;
    }

    #region Membership Packages (Catalog)

    public async Task<List<MembershipPackageDTO>> GetAllPackagesAsync()
    {
        return await _context.MembershipPackages
            .AsNoTracking()
            .Where(p => !p.IsDeleted)
            .OrderBy(p => p.PackageName)
            .Select(p => new MembershipPackageDTO
            {
                Id = p.Id,
                PackageName = p.PackageName,
                PackagePrice = p.PackagePrice,
                Description = p.Description,
                IsActive = p.IsActive
            })
            .ToListAsync();
    }

    public async Task<MembershipPackageDTO?> GetPackageByIdAsync(int packageId)
    {
        return await _context.MembershipPackages
            .AsNoTracking()
            .Where(p => p.Id == packageId && !p.IsDeleted)
            .Select(p => new MembershipPackageDTO
            {
                Id = p.Id,
                PackageName = p.PackageName,
                PackagePrice = p.PackagePrice,
                Description = p.Description,
                IsActive = p.IsActive
            })
            .FirstOrDefaultAsync();
    }

    public async Task<MembershipPackageDTO> CreatePackageAsync(CreateMembershipPackageRequest request)
    {
        if (string.IsNullOrWhiteSpace(request.PackageName))
            throw new ArgumentException("PackageName is required.");

        if (request.PackagePrice < 0)
            throw new ArgumentException("PackagePrice cannot be negative.");

        var package = new MembershipPackage
        {
            PackageName = request.PackageName.Trim(),
            PackagePrice = request.PackagePrice,
            Description = request.Description?.Trim() ?? string.Empty,
            IsActive = true
        };

        _context.MembershipPackages.Add(package);
        await _context.SaveChangesAsync();

        return new MembershipPackageDTO
        {
            Id = package.Id,
            PackageName = package.PackageName,
            PackagePrice = package.PackagePrice,
            Description = package.Description,
            IsActive = package.IsActive
        };
    }

    public async Task<MembershipPackageDTO?> UpdatePackageAsync(int packageId, UpdateMembershipPackageRequest request)
    {
        var package = await _context.MembershipPackages
            .FirstOrDefaultAsync(p => p.Id == packageId && !p.IsDeleted);

        if (package == null) return null;

        if (string.IsNullOrWhiteSpace(request.PackageName))
            throw new ArgumentException("PackageName is required.");

        if (request.PackagePrice < 0)
            throw new ArgumentException("PackagePrice cannot be negative.");

        package.PackageName = request.PackageName.Trim();
        package.PackagePrice = request.PackagePrice;
        package.Description = request.Description?.Trim() ?? string.Empty;
        package.IsActive = request.IsActive;

        await _context.SaveChangesAsync();

        return new MembershipPackageDTO
        {
            Id = package.Id,
            PackageName = package.PackageName,
            PackagePrice = package.PackagePrice,
            Description = package.Description,
            IsActive = package.IsActive
        };
    }

    public async Task<bool> DeletePackageAsync(int packageId)
    {
        var package = await _context.MembershipPackages
            .FirstOrDefaultAsync(p => p.Id == packageId && !p.IsDeleted);

        if (package == null) return false;

        // Soft delete
        package.IsDeleted = true;
        package.IsActive = false;
        await _context.SaveChangesAsync();

        return true;
    }

    #endregion

    #region Users

    public async Task<PagedResult<MembershipUserRowDTO>> GetUsersAsync(string? search, PaginationRequest pagination)
    {
        if (pagination.PageNumber < 1) pagination.PageNumber = 1;
        if (pagination.PageSize < 1) pagination.PageSize = 10;
        if (pagination.PageSize > 200) pagination.PageSize = 200;

        var query = _context.Users
            .AsNoTracking()
            .Where(u => !u.IsDeleted);

        if (!string.IsNullOrWhiteSpace(search))
        {
            var s = search.Trim();
            query = query.Where(u =>
                u.FirstName.Contains(s) ||
                u.LastName.Contains(s) ||
                u.Username.Contains(s));
        }

        var dtoQuery = query
            .OrderBy(u => u.Id)
            .Select(u => new MembershipUserRowDTO
            {
                UserId = u.Id,
                FirstName = u.FirstName,
                LastName = u.LastName,
                Username = u.Username
            });

        var totalCount = await dtoQuery.CountAsync();

        var items = await dtoQuery
            .Skip((pagination.PageNumber - 1) * pagination.PageSize)
            .Take(pagination.PageSize)
            .ToListAsync();

        return new PagedResult<MembershipUserRowDTO>
        {
            Items = items,
            TotalCount = totalCount,
            PageNumber = pagination.PageNumber
        };
    }

    public async Task<UserMembershipDTO?> GetUserMembershipAsync(int userId)
    {
        var user = await _context.Users
            .AsNoTracking()
            .Where(u => u.Id == userId && !u.IsDeleted)
            .Select(u => new { u.Id })
            .FirstOrDefaultAsync();

        if (user == null) return null;

        var membership = await _context.Memberships
            .AsNoTracking()
            .Include(m => m.MembershipPackage)
            .Where(m => m.UserId == userId && !m.IsDeleted)
            .Select(m => new UserMembershipDTO
            {
                MembershipId = m.Id,
                MembershipPackageId = m.MembershipPackageId,
                PackageName = m.MembershipPackage.PackageName,
                StartDate = m.StartDate,
                EndDate = m.EndDate
            })
            .FirstOrDefaultAsync();

        return membership ?? new UserMembershipDTO();
    }

    #endregion

    #region Payment History

    public async Task<PagedResult<MembershipPaymentRowDTO>> GetPaymentsAsync(int userId, PaginationRequest pagination)
    {
        if (pagination.PageNumber < 1) pagination.PageNumber = 1;
        if (pagination.PageSize < 1) pagination.PageSize = 20;
        if (pagination.PageSize > 200) pagination.PageSize = 200;

        var userExists = await _context.Users.AnyAsync(u => u.Id == userId && !u.IsDeleted);
        if (!userExists)
            return new PagedResult<MembershipPaymentRowDTO> { Items = new(), TotalCount = 0, PageNumber = pagination.PageNumber };

        var query = _context.MembershipPaymentHistory
            .AsNoTracking()
            .Include(p => p.MembershipPackage)
            .Where(p => p.UserId == userId && !p.IsDeleted);

        var totalCount = await query.CountAsync();

        var items = await query
            .OrderByDescending(p => p.PaymentDate)
            .Skip((pagination.PageNumber - 1) * pagination.PageSize)
            .Take(pagination.PageSize)
            .Select(p => new MembershipPaymentRowDTO
            {
                Id = p.Id,
                MembershipPackageId = p.MembershipPackageId,
                PackageName = p.MembershipPackage.PackageName,
                AmountPaid = p.AmountPaid,
                PaymentDate = p.PaymentDate,
                StartDate = p.StartDate,
                EndDate = p.EndDate
            })
            .ToListAsync();

        return new PagedResult<MembershipPaymentRowDTO>
        {
            Items = items,
            TotalCount = totalCount,
            PageNumber = pagination.PageNumber
        };
    }

    #endregion

    #region Assign/Renew Membership

    public async Task<bool> AssignMembershipAsync(int userId, AddMembershipPaymentRequest request)
    {
        if (request.EndDate <= request.StartDate)
            throw new ArgumentException("EndDate must be after StartDate.");

        if (request.AmountPaid < 0)
            throw new ArgumentException("AmountPaid cannot be negative.");

        var user = await _context.Users
            .Include(u => u.Membership)
            .FirstOrDefaultAsync(u => u.Id == userId && !u.IsDeleted);

        if (user == null) return false;

        var package = await _context.MembershipPackages
            .FirstOrDefaultAsync(p => p.Id == request.MembershipPackageId && !p.IsDeleted && p.IsActive);

        if (package == null)
            throw new ArgumentException("MembershipPackage not found or inactive.");

        // Create or update membership
        if (user.Membership == null)
        {
            user.Membership = new Membership
            {
                UserId = user.Id,
                MembershipPackageId = request.MembershipPackageId,
                StartDate = request.StartDate,
                EndDate = request.EndDate
            };
            _context.Memberships.Add(user.Membership);
        }
        else
        {
            user.Membership.MembershipPackageId = request.MembershipPackageId;
            user.Membership.StartDate = request.StartDate;
            user.Membership.EndDate = request.EndDate;
        }

        // Add payment history record
        var paymentHistory = new MembershipPaymentHistory
        {
            UserId = user.Id,
            MembershipPackageId = request.MembershipPackageId,
            AmountPaid = request.AmountPaid,
            PaymentDate = request.PaymentDate,
            StartDate = request.StartDate,
            EndDate = request.EndDate
        };

        _context.MembershipPaymentHistory.Add(paymentHistory);
        await _context.SaveChangesAsync();

        return true;
    }

    #endregion
}
