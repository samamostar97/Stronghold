using Microsoft.EntityFrameworkCore;
using Stronghold.Application.Common;
using Stronghold.Application.IRepositories;
using Stronghold.Core.Entities;
using Stronghold.Infrastructure.Data;

namespace Stronghold.Infrastructure.Repositories;

public class BaseRepository<T, TKey> : IRepository<T, TKey>
    where T : BaseEntity
{
    protected readonly StrongholdDbContext _context;
    protected readonly DbSet<T> _dbSet;

    public BaseRepository(StrongholdDbContext context)
    {
        _context = context;
        _dbSet = context.Set<T>();
    }

    public virtual async Task AddAsync(T entity)
    {
        await _dbSet.AddAsync(entity);
        await _context.SaveChangesAsync();
    }

    public virtual IQueryable<T> AsQueryable()
    {
        return _dbSet.Where(e => !e.IsDeleted);
    }

    public virtual async Task DeleteAsync(T entity)
    {
        entity.IsDeleted = true;
        _dbSet.Update(entity);
        await _context.SaveChangesAsync();
    }

    public virtual async Task<IEnumerable<T>> GetAllAsync()
    {
        return await _dbSet.Where(e => !e.IsDeleted).ToListAsync();
    }

    public virtual async Task<T> GetByIdAsync(TKey id)
    {
        var entity = await _dbSet.FindAsync(id);

        if (entity is null || entity.IsDeleted)
            throw new KeyNotFoundException($"Entitet tipa {typeof(T).Name} sa id '{id}' ne postoji.");

        return entity;
    }

    public virtual async Task<PagedResult<T>> GetPagedAsync(IQueryable<T> query, PaginationRequest request)
    {
        var totalCount = await query.CountAsync();
        var items = await query
           .Skip((request.PageNumber - 1) * request.PageSize)
           .Take(request.PageSize)
           .ToListAsync();

        return new PagedResult<T>
        {
            Items = items,
            TotalCount = totalCount,
            PageNumber = request.PageNumber
        };
    }

    public virtual async Task UpdateAsync(T entity)
    {
        _dbSet.Update(entity);
        await _context.SaveChangesAsync();
    }
}
