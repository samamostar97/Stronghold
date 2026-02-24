using Microsoft.EntityFrameworkCore;
using Stronghold.Application.Common;
using Stronghold.Application.Features.MembershipPackages.DTOs;
using Stronghold.Application.IRepositories;
using Stronghold.Core.Entities;
using Stronghold.Infrastructure.Data;

namespace Stronghold.Infrastructure.Repositories;

public class MembershipPackageRepository : IMembershipPackageRepository
{
    private readonly StrongholdDbContext _context;

    public MembershipPackageRepository(StrongholdDbContext context)
    {
        _context = context;
    }

    public async Task<PagedResult<MembershipPackage>> GetPagedAsync(
        MembershipPackageFilter filter,
        CancellationToken cancellationToken = default)
    {
        filter ??= new MembershipPackageFilter();

        var query = _context.MembershipPackages
            .AsNoTracking()
            .Where(x => !x.IsDeleted)
            .AsQueryable();

        if (!string.IsNullOrWhiteSpace(filter.Search))
        {
            var search = filter.Search.Trim().ToLower();
            query = query.Where(x =>
                x.PackageName.ToLower().Contains(search) ||
                x.Description.ToLower().Contains(search));
        }

        if (!string.IsNullOrWhiteSpace(filter.OrderBy))
        {
            query = filter.OrderBy.Trim().ToLowerInvariant() switch
            {
                "packagename" => query.OrderBy(x => x.PackageName).ThenBy(x => x.Id),
                "packagenamedesc" => query.OrderByDescending(x => x.PackageName).ThenByDescending(x => x.Id),
                "priceasc" => query.OrderBy(x => x.PackagePrice).ThenBy(x => x.Id),
                "pricedesc" => query.OrderByDescending(x => x.PackagePrice).ThenByDescending(x => x.Id),
                "createdat" => query.OrderBy(x => x.CreatedAt).ThenBy(x => x.Id),
                "createdatdesc" => query.OrderByDescending(x => x.CreatedAt).ThenByDescending(x => x.Id),
                _ => query.OrderByDescending(x => x.CreatedAt).ThenByDescending(x => x.Id)
            };
        }
        else
        {
            query = query.OrderByDescending(x => x.CreatedAt).ThenByDescending(x => x.Id);
        }

        var totalCount = await query.CountAsync(cancellationToken);
        var items = await query
            .Skip((filter.PageNumber - 1) * filter.PageSize)
            .Take(filter.PageSize)
            .ToListAsync(cancellationToken);

        return new PagedResult<MembershipPackage>
        {
            Items = items,
            TotalCount = totalCount,
            PageNumber = filter.PageNumber
        };
    }

    public Task<MembershipPackage?> GetByIdAsync(int id, CancellationToken cancellationToken = default)
    {
        return _context.MembershipPackages
            .AsNoTracking()
            .FirstOrDefaultAsync(x => x.Id == id && !x.IsDeleted, cancellationToken);
    }

    public Task<bool> ExistsByNameAsync(string packageName, int? excludeId = null, CancellationToken cancellationToken = default)
    {
        var normalized = packageName.Trim().ToLower();
        return _context.MembershipPackages.AnyAsync(
            x => !x.IsDeleted &&
                 x.PackageName.ToLower() == normalized &&
                 (!excludeId.HasValue || x.Id != excludeId.Value),
            cancellationToken);
    }

    public Task<bool> HasActiveMembershipsAsync(int membershipPackageId, CancellationToken cancellationToken = default)
    {
        return _context.Memberships.AnyAsync(
            x => !x.IsDeleted &&
                 x.MembershipPackageId == membershipPackageId &&
                 x.EndDate > DateTime.UtcNow,
            cancellationToken);
    }

    public async Task AddAsync(MembershipPackage entity, CancellationToken cancellationToken = default)
    {
        await _context.MembershipPackages.AddAsync(entity, cancellationToken);
        await _context.SaveChangesAsync(cancellationToken);
    }

    public async Task UpdateAsync(MembershipPackage entity, CancellationToken cancellationToken = default)
    {
        _context.MembershipPackages.Update(entity);
        await _context.SaveChangesAsync(cancellationToken);
    }

    public async Task DeleteAsync(MembershipPackage entity, CancellationToken cancellationToken = default)
    {
        entity.IsDeleted = true;
        _context.MembershipPackages.Update(entity);
        await _context.SaveChangesAsync(cancellationToken);
    }
}
