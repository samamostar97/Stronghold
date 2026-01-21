using MapsterMapper;
using Microsoft.EntityFrameworkCore;
using Stronghold.Application.DTOs.AdminPackageDTO;
using Stronghold.Application.Filters;
using Stronghold.Application.IRepositories;
using Stronghold.Application.IServices;
using Stronghold.Core.Entities;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Stronghold.Infrastructure.Services
{
    public class AdminPackageService : BaseService<MembershipPackage, MembershipPackageDTO, CreateMembershipPackageDTO, UpdateMembershipPackageDTO, MembershipPackageQueryFilter, int>, IAdminPackageService
    {
        public AdminPackageService(IRepository<MembershipPackage, int> repository, IMapper mapper) : base(repository, mapper)
        {
        }
        protected override async Task BeforeCreateAsync(MembershipPackage entity, CreateMembershipPackageDTO dto)
        {
            var packageExists = await _repository.AsQueryable().AnyAsync(x => x.Id == entity.Id);
            if (packageExists)
                throw new InvalidOperationException("Package vec postoji");

        }
        protected override async Task BeforeUpdateAsync(MembershipPackage entity, UpdateMembershipPackageDTO dto)
        {
            var packageExists = await _repository.AsQueryable().AnyAsync(x => x.PackageName.ToLower() == dto.PackageName && x.Id != entity.Id);
            if (packageExists) throw new InvalidOperationException("Paket sa ovim imenom već postoji");
        }
        protected override IQueryable<MembershipPackage> ApplyFilter(IQueryable<MembershipPackage> query, MembershipPackageQueryFilter? filter)
        {
            if (filter == null)
                return query;
            if(!string.IsNullOrEmpty(filter.Search))
                query=query.Where(x=>x.PackageName.ToLower().Contains(filter.Search.ToLower())||
                                  x.Description.ToLower().Contains(filter.Search.ToLower()));
            if(!string.IsNullOrEmpty(filter.OrderBy))
            {
                query = filter.OrderBy.ToLower() switch
                {
                    "packagename" => query.OrderBy(x => x.PackageName),
                    "priceasc" => query.OrderBy(x => x.PackagePrice),
                    "pricedesc" => query.OrderByDescending(x => x.PackagePrice),
                    _ => query.OrderBy(x=>x.CreatedAt)
                };
                return query;

            }
            query = query.OrderBy(x => x.CreatedAt);
            return query;
        }
    }
}
