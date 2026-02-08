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
    public class SupplementCategoryService : BaseService<SupplementCategory, SupplementCategoryResponse, CreateSupplementCategoryRequest, UpdateSupplementCategoryRequest, SupplementCategoryQueryFilter, int>, ISupplementCategoryService
    {
        public SupplementCategoryService(IRepository<SupplementCategory, int> repository, IMapper mapper) : base(repository, mapper)
        {
        }

        protected override async Task BeforeCreateAsync(SupplementCategory entity, CreateSupplementCategoryRequest dto)
        {
            var categoryExists = await _repository.AsQueryable().AnyAsync(x => x.Name.ToLower() == dto.Name.ToLower());
            if (categoryExists) throw new ConflictException("Kategorija sa ovim nazivom već postoji.");
        }

        protected override async Task BeforeUpdateAsync(SupplementCategory entity, UpdateSupplementCategoryRequest dto)
        {
            if (!string.IsNullOrEmpty(dto.Name))
            {
                var categoryExists = await _repository.AsQueryable().AnyAsync(x => x.Name.ToLower() == dto.Name.ToLower() && x.Id != entity.Id);
                if (categoryExists) throw new ConflictException("Kategorija sa ovim nazivom već postoji.");
            }
        }

        protected override async Task BeforeDeleteAsync(SupplementCategory entity)
        {
            var hasSupplements = await _repository.AsQueryable()
                .Where(x => x.Id == entity.Id)
                .SelectMany(x => x.Supplements)
                .AnyAsync();

            if (hasSupplements)
                throw new EntityHasDependentsException("kategoriju", "suplemente");
        }

        protected override IQueryable<SupplementCategory> ApplyFilter(IQueryable<SupplementCategory> query, SupplementCategoryQueryFilter filter)
        {
            if (!string.IsNullOrEmpty(filter.Search))
                query = query.Where(x => x.Name.ToLower().Contains(filter.Search.ToLower()));

            if (!string.IsNullOrEmpty(filter.OrderBy))
            {
                return filter.OrderBy.ToLower() switch
                {
                    "naziv" => query.OrderBy(x => x.Name),
                    "createdatdesc" => query.OrderByDescending(x => x.CreatedAt),
                    _ => query.OrderBy(x => x.CreatedAt)
                };
            }

            return query.OrderBy(x => x.CreatedAt);
        }
    }
}
