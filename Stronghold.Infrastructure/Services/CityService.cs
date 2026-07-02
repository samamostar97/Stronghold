using Microsoft.EntityFrameworkCore;
using Stronghold.Application.DTOs.Cities;
using Stronghold.Application.Exceptions;
using Stronghold.Application.Interfaces;
using Stronghold.Core.Entities;
using Stronghold.Infrastructure.Data;

namespace Stronghold.Infrastructure.Services;

public class CityService : BaseCrudService<City, CityResponse, CitySearch, CityUpsertRequest, CityUpsertRequest>,
    ICityService
{
    public CityService(StrongholdDbContext db) : base(db)
    {
    }

    protected override IQueryable<City> ApplyFilter(IQueryable<City> query, CitySearch search)
    {
        if (!string.IsNullOrWhiteSpace(search.Name))
        {
            query = query.Where(c => c.Name.Contains(search.Name.Trim()));
        }
        return query.OrderBy(c => c.Name);
    }

    protected override async Task BeforeInsertAsync(City entity, CityUpsertRequest request)
    {
        await ValidateUniqueNameAsync(request.Name, null);
    }

    protected override async Task BeforeUpdateAsync(City entity, CityUpsertRequest request)
    {
        await ValidateUniqueNameAsync(request.Name, entity.Id);
    }

    protected override async Task BeforeDeleteAsync(City entity)
    {
        if (await Db.Users.AnyAsync(u => u.CityId == entity.Id))
        {
            throw new BusinessException("Grad se ne može obrisati jer ga koriste adrese korisnika.");
        }
        if (await Db.Orders.AnyAsync(o => o.DeliveryCityId == entity.Id))
        {
            throw new BusinessException("Grad se ne može obrisati jer ga koriste adrese dostave narudžbi.");
        }
    }

    private async Task ValidateUniqueNameAsync(string name, int? excludeId)
    {
        if (await Db.Cities.AnyAsync(c => c.Name == name && (excludeId == null || c.Id != excludeId)))
        {
            throw new BusinessException("Grad sa ovim nazivom već postoji.");
        }
    }
}
