using MapsterMapper;
using Microsoft.EntityFrameworkCore;
using Stronghold.Application.DTOs.Request;
using Stronghold.Application.DTOs.Response;
using Stronghold.Application.Exceptions;
using Stronghold.Application.Filters;
using Stronghold.Application.IRepositories;
using Stronghold.Application.IServices;
using Stronghold.Core.Entities;

namespace Stronghold.Infrastructure.Services
{
    public class MembershipPackageService : BaseService<MembershipPackage, MembershipPackageResponse, CreateMembershipPackageRequest, UpdateMembershipPackageRequest, MembershipPackageQueryFilter, int>, IMembershipPackageService
    {
        public MembershipPackageService(IRepository<MembershipPackage, int> repository, IMapper mapper) : base(repository, mapper)
        {
        }

        protected override async Task BeforeCreateAsync(MembershipPackage entity, CreateMembershipPackageRequest dto)
        {
            var packageExists = await _repository.AsQueryable().AnyAsync(x => x.PackageName.ToLower() == dto.PackageName.ToLower());
            if (packageExists)
                throw new ConflictException("Paket sa ovim imenom već postoji.");
        }

        protected override async Task BeforeUpdateAsync(MembershipPackage entity, UpdateMembershipPackageRequest dto)
        {
            if (!string.IsNullOrEmpty(dto.PackageName))
            {
                var packageExists = await _repository.AsQueryable().AnyAsync(x => x.PackageName.ToLower() == dto.PackageName.ToLower() && x.Id != entity.Id);
                if (packageExists) throw new ConflictException("Paket sa ovim imenom već postoji.");
            }
        }

        protected override async Task BeforeDeleteAsync(MembershipPackage entity)
        {
            var hasActiveMemberships = await _repository.AsQueryable()
                .Where(x => x.Id == entity.Id)
                .SelectMany(x => x.Memberships)
                .AnyAsync(m => !m.IsDeleted && m.EndDate > DateTime.UtcNow);

            if (hasActiveMemberships)
                throw new EntityHasDependentsException("paket članarine", "aktivne članove");
        }

        protected override IQueryable<MembershipPackage> ApplyFilter(IQueryable<MembershipPackage> query, MembershipPackageQueryFilter filter)
        {
            if (!string.IsNullOrEmpty(filter.Search))
                query = query.Where(x => x.PackageName.ToLower().Contains(filter.Search.ToLower()) ||
                                      x.Description.ToLower().Contains(filter.Search.ToLower()));

            if (!string.IsNullOrEmpty(filter.OrderBy))
            {
                return filter.OrderBy.ToLower() switch
                {
                    "packagename" => query.OrderBy(x => x.PackageName),
                    "priceasc" => query.OrderBy(x => x.PackagePrice),
                    "pricedesc" => query.OrderByDescending(x => x.PackagePrice),
                    _ => query.OrderBy(x => x.CreatedAt)
                };
            }

            return query.OrderBy(x => x.CreatedAt);
        }
    }
}
