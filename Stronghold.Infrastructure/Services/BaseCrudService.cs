using Mapster;
using Stronghold.Application.Common;
using Stronghold.Application.Exceptions;
using Stronghold.Application.Interfaces;
using Stronghold.Core.Entities;
using Stronghold.Infrastructure.Data;

namespace Stronghold.Infrastructure.Services;

public abstract class BaseCrudService<TEntity, TResponse, TSearch, TInsert, TUpdate>
    : BaseService<TEntity, TResponse, TSearch>, ICrudService<TResponse, TSearch, TInsert, TUpdate>
    where TEntity : BaseEntity, new()
    where TSearch : BaseSearchObject
{
    protected BaseCrudService(StrongholdDbContext db) : base(db)
    {
    }

    public virtual async Task<TResponse> InsertAsync(TInsert request)
    {
        var entity = request!.Adapt<TEntity>();
        await BeforeInsertAsync(entity, request);
        Db.Set<TEntity>().Add(entity);
        await Db.SaveChangesAsync();
        return await GetByIdAsync(entity.Id);
    }

    public virtual async Task<TResponse> UpdateAsync(int id, TUpdate request)
    {
        var entity = await Db.Set<TEntity>().FindAsync(id)
            ?? throw new NotFoundException("Traženi zapis ne postoji.");

        request!.Adapt(entity);
        await BeforeUpdateAsync(entity, request);
        await Db.SaveChangesAsync();
        return await GetByIdAsync(id);
    }

    public virtual async Task DeleteAsync(int id)
    {
        var entity = await Db.Set<TEntity>().FindAsync(id)
            ?? throw new NotFoundException("Traženi zapis ne postoji.");

        await BeforeDeleteAsync(entity);
        Db.Set<TEntity>().Remove(entity);
        await Db.SaveChangesAsync();
    }

    /// <summary>Validacije i dopune prije snimanja (unique provjere, hashiranje, slike...).</summary>
    protected virtual Task BeforeInsertAsync(TEntity entity, TInsert request) => Task.CompletedTask;

    protected virtual Task BeforeUpdateAsync(TEntity entity, TUpdate request) => Task.CompletedTask;

    /// <summary>Provjera zavisnih zapisa - brisanje se odbija uz jasnu poruku zasto.</summary>
    protected virtual Task BeforeDeleteAsync(TEntity entity) => Task.CompletedTask;
}
