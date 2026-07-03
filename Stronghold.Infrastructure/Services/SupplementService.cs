using Microsoft.EntityFrameworkCore;
using Stronghold.Application.DTOs.Supplements;
using Stronghold.Application.Exceptions;
using Stronghold.Application.Interfaces;
using Stronghold.Core.Entities;
using Stronghold.Infrastructure.Data;
using Stronghold.Infrastructure.Security;

namespace Stronghold.Infrastructure.Services;

public class SupplementService
    : BaseCrudService<Supplement, SupplementResponse, SupplementSearch, SupplementUpsertRequest, SupplementUpsertRequest>,
      ISupplementService
{
    public SupplementService(StrongholdDbContext db) : base(db)
    {
    }

    protected override IQueryable<Supplement> ApplyFilter(IQueryable<Supplement> query, SupplementSearch search)
    {
        if (!string.IsNullOrWhiteSpace(search.Text))
        {
            query = query.Where(s => s.Name.Contains(search.Text.Trim()));
        }
        if (search.CategoryId.HasValue)
        {
            query = query.Where(s => s.CategoryId == search.CategoryId);
        }
        if (search.SupplierId.HasValue)
        {
            query = query.Where(s => s.SupplierId == search.SupplierId);
        }
        return query.OrderByDescending(s => s.Id);
    }

    protected override async Task BeforeInsertAsync(Supplement entity, SupplementUpsertRequest request)
    {
        await ValidateReferencesAsync(request);
        if (!string.IsNullOrWhiteSpace(request.ImageBase64))
        {
            entity.ImageData = ImageValidator.DecodeAndValidate(request.ImageBase64);
        }
    }

    protected override async Task BeforeUpdateAsync(Supplement entity, SupplementUpsertRequest request)
    {
        await ValidateReferencesAsync(request);
        if (!string.IsNullOrWhiteSpace(request.ImageBase64))
        {
            entity.ImageData = ImageValidator.DecodeAndValidate(request.ImageBase64);
        }
    }

    protected override async Task BeforeDeleteAsync(Supplement entity)
    {
        if (await Db.OrderItems.AnyAsync(i => i.SupplementId == entity.Id))
        {
            throw new BusinessException("Suplement se ne može obrisati jer postoje narudžbe koje ga sadrže.");
        }
    }

    public async Task<(byte[] Data, string ContentType)> GetImageAsync(int id)
    {
        var image = await Db.Supplements.AsNoTracking()
            .Where(s => s.Id == id)
            .Select(s => s.ImageData)
            .FirstOrDefaultAsync();

        if (image == null)
        {
            throw new NotFoundException("Suplement nema sliku.");
        }
        return (image, ImageValidator.GetContentType(image) ?? "application/octet-stream");
    }

    private async Task ValidateReferencesAsync(SupplementUpsertRequest request)
    {
        if (!await Db.SupplementCategories.AnyAsync(c => c.Id == request.CategoryId))
        {
            throw new BusinessException("Odabrana kategorija ne postoji.");
        }
        if (!await Db.Suppliers.AnyAsync(s => s.Id == request.SupplierId))
        {
            throw new BusinessException("Odabrani dobavljač ne postoji.");
        }
    }
}
