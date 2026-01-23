using MapsterMapper;
using Microsoft.EntityFrameworkCore;
using Stronghold.Application.DTOs.AdminCategoryDTO;
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
    public class AdminCategoryService : BaseService<SupplementCategory, SupplementCategoryDTO, CreateSupplementCategoryDTO, UpdateSupplementCategoryDTO, SupplementCategoryQueryFilter, int>, IAdminCategoryService
    {
        public AdminCategoryService(IRepository<SupplementCategory, int> repository, IMapper mapper) : base(repository, mapper)
        {
        }
        protected override async Task BeforeCreateAsync(SupplementCategory entity, CreateSupplementCategoryDTO dto)
        {
            var categoryExists = await _repository.AsQueryable().AnyAsync(x => x.Name.ToLower() == dto.Name.ToLower());
            if (categoryExists) throw new InvalidOperationException("Kategorija sa ovim nazivom već postoji");
        }
        protected override async Task BeforeUpdateAsync(SupplementCategory entity, UpdateSupplementCategoryDTO dto)
        {
            var categoryExists = await _repository.AsQueryable().AnyAsync(x => x.Name.ToLower() == dto.Name.ToLower() && !x.IsDeleted&&x.Id!=entity.Id);
            if (categoryExists) throw new InvalidOperationException("Kategorija sa ovim nazivom već postoji");
        }
        protected override IQueryable<SupplementCategory> ApplyFilter(IQueryable<SupplementCategory> query, SupplementCategoryQueryFilter? filter)
        {
            if (filter == null)
                return query;
            if(!string.IsNullOrEmpty(filter.Search))
                query=query.Where(x=>x.Name.ToLower().Contains(filter.Search.ToLower()));
            if(!string.IsNullOrEmpty(filter.OrderBy))
            {
                query = filter.OrderBy.ToLower() switch
                {
                    "naziv" => query.OrderBy(x => x.Name),
                    "createdatdesc" => query.OrderByDescending(x => x.CreatedAt),
                    _ => query.OrderBy(x => x.CreatedAt)
                };
                return query;
            }
            query = query.OrderBy(x => x.CreatedAt);
            return query;
        }
    }
}
