using Mapster;
using Microsoft.EntityFrameworkCore;
using Stronghold.Application.Common;
using Stronghold.Application.Exceptions;
using Stronghold.Application.Interfaces;
using Stronghold.Core.Entities;
using Stronghold.Infrastructure.Data;

namespace Stronghold.Infrastructure.Services;

/// <summary>
/// Zajednicka read logika: paginacija + filter + projekcija u DTO na nivou SQL upita
/// (velika binarna polja se ne ucitavaju u listama).
/// </summary>
public abstract class BaseService<TEntity, TResponse, TSearch> : IService<TResponse, TSearch>
    where TEntity : BaseEntity
    where TSearch : BaseSearchObject
{
    protected readonly StrongholdDbContext Db;

    protected BaseService(StrongholdDbContext db)
    {
        Db = db;
    }

    public virtual async Task<PagedResult<TResponse>> GetPagedAsync(TSearch search)
    {
        var query = ApplyFilter(Db.Set<TEntity>().AsNoTracking(), search);
        var totalCount = await query.CountAsync();
        var items = await query
            .Skip((search.Page - 1) * search.PageSize)
            .Take(search.PageSize)
            .ProjectToType<TResponse>()
            .ToListAsync();

        return new PagedResult<TResponse> { Items = items, TotalCount = totalCount };
    }

    public virtual async Task<TResponse> GetByIdAsync(int id)
    {
        var response = await Db.Set<TEntity>().AsNoTracking()
            .Where(e => e.Id == id)
            .ProjectToType<TResponse>()
            .FirstOrDefaultAsync();

        return response ?? throw new NotFoundException("Traženi zapis ne postoji.");
    }

    /// <summary>Filteri + sortiranje; podrazumijevano najnoviji zapisi na vrhu.</summary>
    protected virtual IQueryable<TEntity> ApplyFilter(IQueryable<TEntity> query, TSearch search)
    {
        return query.OrderByDescending(e => e.Id);
    }
}
