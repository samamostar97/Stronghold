using Microsoft.EntityFrameworkCore;
using Stronghold.Application.DTOs.Suppliers;
using Stronghold.Application.Exceptions;
using Stronghold.Application.Interfaces;
using Stronghold.Core.Entities;
using Stronghold.Infrastructure.Data;

namespace Stronghold.Infrastructure.Services;

public class SupplierService
    : BaseCrudService<Supplier, SupplierResponse, SupplierSearch, SupplierUpsertRequest, SupplierUpsertRequest>,
      ISupplierService
{
    public SupplierService(StrongholdDbContext db) : base(db)
    {
    }

    protected override IQueryable<Supplier> ApplyFilter(IQueryable<Supplier> query, SupplierSearch search)
    {
        if (!string.IsNullOrWhiteSpace(search.Name))
        {
            query = query.Where(s => s.Name.Contains(search.Name.Trim()));
        }
        return query.OrderBy(s => s.Name);
    }

    protected override async Task BeforeInsertAsync(Supplier entity, SupplierUpsertRequest request)
    {
        await ValidateUniqueNameAsync(request.Name, null);
    }

    protected override async Task BeforeUpdateAsync(Supplier entity, SupplierUpsertRequest request)
    {
        await ValidateUniqueNameAsync(request.Name, entity.Id);
    }

    protected override async Task BeforeDeleteAsync(Supplier entity)
    {
        if (await Db.Supplements.AnyAsync(s => s.SupplierId == entity.Id))
        {
            throw new BusinessException("Dobavljač se ne može obrisati jer postoje suplementi vezani za njega.");
        }
    }

    private async Task ValidateUniqueNameAsync(string name, int? excludeId)
    {
        if (await Db.Suppliers.AnyAsync(s => s.Name == name && (excludeId == null || s.Id != excludeId)))
        {
            throw new BusinessException("Dobavljač sa ovim nazivom već postoji.");
        }
    }
}
