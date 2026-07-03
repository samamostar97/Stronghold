using Microsoft.EntityFrameworkCore;
using Stronghold.Application.DTOs.SupplementCategories;
using Stronghold.Application.Exceptions;
using Stronghold.Application.Interfaces;
using Stronghold.Core.Entities;
using Stronghold.Infrastructure.Data;

namespace Stronghold.Infrastructure.Services;

public class SupplementCategoryService
    : BaseCrudService<SupplementCategory, SupplementCategoryResponse, SupplementCategorySearch,
        SupplementCategoryUpsertRequest, SupplementCategoryUpsertRequest>,
      ISupplementCategoryService
{
    public SupplementCategoryService(StrongholdDbContext db) : base(db)
    {
    }

    protected override IQueryable<SupplementCategory> ApplyFilter(
        IQueryable<SupplementCategory> query, SupplementCategorySearch search)
    {
        if (!string.IsNullOrWhiteSpace(search.Name))
        {
            query = query.Where(c => c.Name.Contains(search.Name.Trim()));
        }
        return query.OrderBy(c => c.Name);
    }

    protected override async Task BeforeInsertAsync(SupplementCategory entity, SupplementCategoryUpsertRequest request)
    {
        await ValidateUniqueNameAsync(request.Name, null);
    }

    protected override async Task BeforeUpdateAsync(SupplementCategory entity, SupplementCategoryUpsertRequest request)
    {
        await ValidateUniqueNameAsync(request.Name, entity.Id);
    }

    protected override async Task BeforeDeleteAsync(SupplementCategory entity)
    {
        if (await Db.Supplements.AnyAsync(s => s.CategoryId == entity.Id))
        {
            throw new BusinessException("Kategorija se ne može obrisati jer sadrži suplemente.");
        }
    }

    private async Task ValidateUniqueNameAsync(string name, int? excludeId)
    {
        if (await Db.SupplementCategories.AnyAsync(c => c.Name == name && (excludeId == null || c.Id != excludeId)))
        {
            throw new BusinessException("Kategorija sa ovim nazivom već postoji.");
        }
    }
}
