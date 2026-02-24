using Microsoft.EntityFrameworkCore;
using Stronghold.Application.Common;
using Stronghold.Application.Features.SupplementCategories.DTOs;
using Stronghold.Application.IRepositories;
using Stronghold.Core.Entities;
using Stronghold.Infrastructure.Data;

namespace Stronghold.Infrastructure.Repositories;

public class SupplementCategoryRepository : ISupplementCategoryRepository
{
    private readonly StrongholdDbContext _context;

    public SupplementCategoryRepository(StrongholdDbContext context)
    {
        _context = context;
    }

    public async Task<PagedResult<SupplementCategory>> GetPagedAsync(
        SupplementCategoryFilter filter,
        CancellationToken cancellationToken = default)
    {
        filter ??= new SupplementCategoryFilter();

        var query = _context.SupplementCategories
            .AsNoTracking()
            .Where(x => !x.IsDeleted)
            .AsQueryable();

        if (!string.IsNullOrWhiteSpace(filter.Search))
        {
            var search = filter.Search.Trim().ToLower();
            query = query.Where(x => x.Name.ToLower().Contains(search));
        }

        if (!string.IsNullOrWhiteSpace(filter.OrderBy))
        {
            query = filter.OrderBy.Trim().ToLowerInvariant() switch
            {
                "name" => query.OrderBy(x => x.Name).ThenBy(x => x.Id),
                "namedesc" => query.OrderByDescending(x => x.Name).ThenByDescending(x => x.Id),
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

        return new PagedResult<SupplementCategory>
        {
            Items = items,
            TotalCount = totalCount,
            PageNumber = filter.PageNumber
        };
    }

    public Task<SupplementCategory?> GetByIdAsync(int id, CancellationToken cancellationToken = default)
    {
        return _context.SupplementCategories
            .AsNoTracking()
            .FirstOrDefaultAsync(x => x.Id == id && !x.IsDeleted, cancellationToken);
    }

    public Task<bool> ExistsByNameAsync(string name, int? excludeId = null, CancellationToken cancellationToken = default)
    {
        var normalized = name.Trim().ToLower();
        return _context.SupplementCategories.AnyAsync(
            x => !x.IsDeleted &&
                 x.Name.ToLower() == normalized &&
                 (!excludeId.HasValue || x.Id != excludeId.Value),
            cancellationToken);
    }

    public Task<bool> HasSupplementsAsync(int supplementCategoryId, CancellationToken cancellationToken = default)
    {
        return _context.Supplements.AnyAsync(
            x => x.SupplementCategoryId == supplementCategoryId && !x.IsDeleted,
            cancellationToken);
    }

    public async Task AddAsync(SupplementCategory entity, CancellationToken cancellationToken = default)
    {
        await _context.SupplementCategories.AddAsync(entity, cancellationToken);
        await _context.SaveChangesAsync(cancellationToken);
    }

    public async Task UpdateAsync(SupplementCategory entity, CancellationToken cancellationToken = default)
    {
        _context.SupplementCategories.Update(entity);
        await _context.SaveChangesAsync(cancellationToken);
    }

    public async Task DeleteAsync(SupplementCategory entity, CancellationToken cancellationToken = default)
    {
        entity.IsDeleted = true;
        _context.SupplementCategories.Update(entity);
        await _context.SaveChangesAsync(cancellationToken);
    }
}
