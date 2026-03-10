using Microsoft.EntityFrameworkCore;
using Stronghold.Application.Interfaces;
using Stronghold.Domain.Entities;
using Stronghold.Domain.Exceptions;
using Stronghold.Infrastructure.Persistence;

namespace Stronghold.Infrastructure.Services;

public class UndoService : IUndoService
{
    private readonly StrongholdDbContext _context;

    public UndoService(StrongholdDbContext context)
    {
        _context = context;
    }

    public async Task UndoDeleteAsync(string entityType, int entityId)
    {
        switch (entityType)
        {
            case "User":
                await RestoreEntityAsync<User>(entityId);
                break;
            case "Staff":
                await RestoreEntityAsync<Staff>(entityId);
                break;
            case "MembershipPackage":
                await RestoreEntityAsync<MembershipPackage>(entityId);
                break;
            case "ProductCategory":
                await RestoreEntityAsync<ProductCategory>(entityId);
                break;
            case "Supplier":
                await RestoreEntityAsync<Supplier>(entityId);
                break;
            case "Product":
                await RestoreEntityAsync<Product>(entityId);
                break;
            case "Review":
                await RestoreEntityAsync<Review>(entityId);
                break;
            default:
                throw new InvalidOperationException($"Nepoznat tip entiteta: {entityType}");
        }
    }

    private async Task RestoreEntityAsync<T>(int entityId) where T : BaseEntity
    {
        var entity = await _context.Set<T>()
            .IgnoreQueryFilters()
            .FirstOrDefaultAsync(e => e.Id == entityId)
            ?? throw new NotFoundException(typeof(T).Name, entityId);

        if (!entity.IsDeleted)
            throw new InvalidOperationException("Entitet nije obrisan.");

        entity.IsDeleted = false;
        entity.DeletedAt = null;

        await _context.SaveChangesAsync();
    }
}
