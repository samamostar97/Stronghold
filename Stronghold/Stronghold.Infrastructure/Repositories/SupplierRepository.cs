using Microsoft.EntityFrameworkCore;
using Stronghold.Application.Common;
using Stronghold.Application.Features.Suppliers.DTOs;
using Stronghold.Application.IRepositories;
using Stronghold.Core.Entities;
using Stronghold.Infrastructure.Data;

namespace Stronghold.Infrastructure.Repositories;

public class SupplierRepository : ISupplierRepository
{
    private readonly StrongholdDbContext _context;

    public SupplierRepository(StrongholdDbContext context)
    {
        _context = context;
    }

    public async Task<PagedResult<Supplier>> GetPagedAsync(
        SupplierFilter filter,
        CancellationToken cancellationToken = default)
    {
        filter ??= new SupplierFilter();

        var query = _context.Suppliers
            .AsNoTracking()
            .Where(x => !x.IsDeleted)
            .AsQueryable();

        if (!string.IsNullOrWhiteSpace(filter.Search))
        {
            var search = filter.Search.Trim().ToLower();
            query = query.Where(x =>
                x.Name.ToLower().Contains(search) ||
                (x.Website != null && x.Website.ToLower().Contains(search)));
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

        return new PagedResult<Supplier>
        {
            Items = items,
            TotalCount = totalCount,
            PageNumber = filter.PageNumber
        };
    }

    public Task<Supplier?> GetByIdAsync(int id, CancellationToken cancellationToken = default)
    {
        return _context.Suppliers
            .AsNoTracking()
            .FirstOrDefaultAsync(x => x.Id == id && !x.IsDeleted, cancellationToken);
    }

    public Task<bool> ExistsByNameAsync(string name, int? excludeId = null, CancellationToken cancellationToken = default)
    {
        var normalized = name.Trim().ToLower();
        return _context.Suppliers.AnyAsync(
            x => !x.IsDeleted &&
                 x.Name.ToLower() == normalized &&
                 (!excludeId.HasValue || x.Id != excludeId.Value),
            cancellationToken);
    }

    public Task<bool> HasSupplementsAsync(int supplierId, CancellationToken cancellationToken = default)
    {
        return _context.Supplements.AnyAsync(x => x.SupplierId == supplierId && !x.IsDeleted, cancellationToken);
    }

    public async Task AddAsync(Supplier entity, CancellationToken cancellationToken = default)
    {
        await _context.Suppliers.AddAsync(entity, cancellationToken);
        await _context.SaveChangesAsync(cancellationToken);
    }

    public async Task UpdateAsync(Supplier entity, CancellationToken cancellationToken = default)
    {
        _context.Suppliers.Update(entity);
        await _context.SaveChangesAsync(cancellationToken);
    }

    public async Task DeleteAsync(Supplier entity, CancellationToken cancellationToken = default)
    {
        entity.IsDeleted = true;
        _context.Suppliers.Update(entity);
        await _context.SaveChangesAsync(cancellationToken);
    }
}
