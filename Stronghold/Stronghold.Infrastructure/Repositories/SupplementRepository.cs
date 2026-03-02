using Microsoft.EntityFrameworkCore;
using Stronghold.Application.Common;
using Stronghold.Application.Features.Supplements.DTOs;
using Stronghold.Application.IRepositories;
using Stronghold.Core.Entities;
using Stronghold.Infrastructure.Data;

namespace Stronghold.Infrastructure.Repositories;

public class SupplementRepository : ISupplementRepository
{
    private readonly StrongholdDbContext _context;

    public SupplementRepository(StrongholdDbContext context)
    {
        _context = context;
    }

    public async Task<PagedResult<Supplement>> GetPagedAsync(
        SupplementFilter filter,
        CancellationToken cancellationToken = default)
    {
        filter ??= new SupplementFilter();

        var query = _context.Supplements
            .AsNoTracking()
            .Where(x => !x.IsDeleted)
            .Include(x => x.Supplier)
            .Include(x => x.SupplementCategory)
            .AsQueryable();

        if (!string.IsNullOrWhiteSpace(filter.Search))
        {
            var search = filter.Search.Trim().ToLower();
            query = query.Where(x =>
                x.Name.ToLower().Contains(search) ||
                (x.Supplier != null && x.Supplier.Name.ToLower().Contains(search)) ||
                (x.SupplementCategory != null && x.SupplementCategory.Name.ToLower().Contains(search)));
        }

        if (filter.SupplementCategoryId.HasValue)
        {
            query = query.Where(x => x.SupplementCategoryId == filter.SupplementCategoryId.Value);
        }

        if (!string.IsNullOrWhiteSpace(filter.OrderBy))
        {
            query = filter.OrderBy.Trim().ToLowerInvariant() switch
            {
                "name" => query.OrderBy(x => x.Name).ThenBy(x => x.Id),
                "namedesc" => query.OrderByDescending(x => x.Name).ThenByDescending(x => x.Id),
                "price" => query.OrderBy(x => x.Price).ThenBy(x => x.Id),
                "pricedesc" => query.OrderByDescending(x => x.Price).ThenByDescending(x => x.Id),
                "category" => query.OrderBy(x => x.SupplementCategory.Name).ThenBy(x => x.Id),
                "categorydesc" => query.OrderByDescending(x => x.SupplementCategory.Name).ThenByDescending(x => x.Id),
                "supplier" => query.OrderBy(x => x.Supplier.Name).ThenBy(x => x.Id),
                "supplierdesc" => query.OrderByDescending(x => x.Supplier.Name).ThenByDescending(x => x.Id),
                "createdat" => query.OrderBy(x => x.CreatedAt).ThenBy(x => x.Id),
                "createdatdesc" => query.OrderByDescending(x => x.CreatedAt).ThenByDescending(x => x.Id),
                "stock" => query.OrderBy(x => x.StockQuantity).ThenBy(x => x.Id),
                "stockdesc" => query.OrderByDescending(x => x.StockQuantity).ThenByDescending(x => x.Id),
                _ => query.OrderBy(x => x.StockQuantity).ThenBy(x => x.Id)
            };
        }
        else
        {
            query = query.OrderBy(x => x.StockQuantity).ThenBy(x => x.Id);
        }

        var totalCount = await query.CountAsync(cancellationToken);
        var items = await query
            .Skip((filter.PageNumber - 1) * filter.PageSize)
            .Take(filter.PageSize)
            .ToListAsync(cancellationToken);

        return new PagedResult<Supplement>
        {
            Items = items,
            TotalCount = totalCount,
            PageNumber = filter.PageNumber
        };
    }

    public Task<Supplement?> GetByIdAsync(int id, CancellationToken cancellationToken = default)
    {
        return _context.Supplements
            .AsNoTracking()
            .Include(x => x.Supplier)
            .Include(x => x.SupplementCategory)
            .FirstOrDefaultAsync(x => x.Id == id && !x.IsDeleted, cancellationToken);
    }

    public Task<bool> ExistsByNameAsync(string name, int? excludeId = null, CancellationToken cancellationToken = default)
    {
        var normalized = name.Trim().ToLower();
        return _context.Supplements.AnyAsync(
            x => !x.IsDeleted &&
                 x.Name.ToLower() == normalized &&
                 (!excludeId.HasValue || x.Id != excludeId.Value),
            cancellationToken);
    }

    public Task<bool> SupplementCategoryExistsAsync(int supplementCategoryId, CancellationToken cancellationToken = default)
    {
        return _context.SupplementCategories.AnyAsync(
            x => x.Id == supplementCategoryId && !x.IsDeleted,
            cancellationToken);
    }

    public Task<bool> SupplierExistsAsync(int supplierId, CancellationToken cancellationToken = default)
    {
        return _context.Suppliers.AnyAsync(
            x => x.Id == supplierId && !x.IsDeleted,
            cancellationToken);
    }

    public Task<bool> HasReviewsAsync(int supplementId, CancellationToken cancellationToken = default)
    {
        return _context.Reviews.AnyAsync(
            x => x.SupplementId == supplementId && !x.IsDeleted,
            cancellationToken);
    }

    public async Task<IReadOnlyList<Review>> GetReviewsAsync(int supplementId, CancellationToken cancellationToken = default)
    {
        return await _context.Reviews
            .AsNoTracking()
            .Include(x => x.User)
            .Where(x => !x.IsDeleted && x.SupplementId == supplementId)
            .OrderByDescending(x => x.CreatedAt)
            .ToListAsync(cancellationToken);
    }

    public async Task<IReadOnlyList<Supplement>> GetRecommendationCandidatesAsync(
        IReadOnlyCollection<int> excludedSupplementIds,
        CancellationToken cancellationToken = default)
    {
        var query = _context.Supplements
            .AsNoTracking()
            .Where(x => !x.IsDeleted)
            .Include(x => x.SupplementCategory)
            .Include(x => x.Supplier)
            .Include(x => x.Reviews.Where(r => !r.IsDeleted))
            .AsQueryable();

        if (excludedSupplementIds.Count > 0)
        {
            query = query.Where(x => !excludedSupplementIds.Contains(x.Id));
        }

        return await query.ToListAsync(cancellationToken);
    }

    public async Task AddAsync(Supplement entity, CancellationToken cancellationToken = default)
    {
        await _context.Supplements.AddAsync(entity, cancellationToken);
        await _context.SaveChangesAsync(cancellationToken);
    }

    public async Task UpdateAsync(Supplement entity, CancellationToken cancellationToken = default)
    {
        _context.Supplements.Update(entity);
        await _context.SaveChangesAsync(cancellationToken);
    }

    public async Task DeleteAsync(Supplement entity, CancellationToken cancellationToken = default)
    {
        entity.IsDeleted = true;
        _context.Supplements.Update(entity);
        await _context.SaveChangesAsync(cancellationToken);
    }

    public async Task AddStockLogAsync(StockLog log, CancellationToken cancellationToken = default)
    {
        await _context.StockLogs.AddAsync(log, cancellationToken);
        await _context.SaveChangesAsync(cancellationToken);
    }
}
