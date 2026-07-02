using Microsoft.EntityFrameworkCore;
using Stronghold.Application.DTOs.MembershipPackages;
using Stronghold.Application.Exceptions;
using Stronghold.Application.Interfaces;
using Stronghold.Core.Entities;
using Stronghold.Infrastructure.Data;

namespace Stronghold.Infrastructure.Services;

public class MembershipPackageService
    : BaseCrudService<MembershipPackage, MembershipPackageResponse, MembershipPackageSearch,
        MembershipPackageUpsertRequest, MembershipPackageUpsertRequest>,
      IMembershipPackageService
{
    public MembershipPackageService(StrongholdDbContext db) : base(db)
    {
    }

    protected override IQueryable<MembershipPackage> ApplyFilter(
        IQueryable<MembershipPackage> query, MembershipPackageSearch search)
    {
        if (!string.IsNullOrWhiteSpace(search.Name))
        {
            query = query.Where(p => p.Name.Contains(search.Name.Trim()));
        }
        return query.OrderByDescending(p => p.Id);
    }

    protected override async Task BeforeInsertAsync(MembershipPackage entity, MembershipPackageUpsertRequest request)
    {
        await ValidateUniqueNameAsync(request.Name, null);
    }

    protected override async Task BeforeUpdateAsync(MembershipPackage entity, MembershipPackageUpsertRequest request)
    {
        await ValidateUniqueNameAsync(request.Name, entity.Id);
    }

    protected override async Task BeforeDeleteAsync(MembershipPackage entity)
    {
        if (await Db.Memberships.AnyAsync(m => m.PackageId == entity.Id))
        {
            throw new BusinessException("Paket se ne može obrisati jer postoje članarine vezane za njega.");
        }
    }

    private async Task ValidateUniqueNameAsync(string name, int? excludeId)
    {
        if (await Db.MembershipPackages.AnyAsync(p => p.Name == name && (excludeId == null || p.Id != excludeId)))
        {
            throw new BusinessException("Paket sa ovim nazivom već postoji.");
        }
    }
}
