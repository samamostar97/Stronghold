using MapsterMapper;
using Microsoft.AspNetCore.Http;
using Stronghold.Application.DTOs.AdminCategoriesDTO;
using Stronghold.Application.Filters;
using Stronghold.Application.IRepositories;
using Stronghold.Application.IServices;
using Stronghold.Core.Entities;

namespace Stronghold.Infrastructure.Services
{
    public class AdminCategoryService : BaseService<SupplementCategory, CategoryDTO, CreateCategoryDTO, UpdateCategoriesDTO, CategoryQueryFilter, int>, IAdminCategoryService
    {
        private readonly ICategoryRepository _categoryRepository;
        private readonly IMapper _mapper;
        public AdminCategoryService(ICategoryRepository repository, IMapper mapper) : base(repository, mapper)
        {
            _categoryRepository = repository;
            _mapper=mapper;
        }
        protected override IQueryable<SupplementCategory> ApplyFilter(IQueryable<SupplementCategory> query, CategoryQueryFilter? filter)
        {
            // Always exclude soft-deleted categories
            query = query.Where(c => !c.IsDeleted);

            if (filter == null)
                return query;

            // Filter by search term (name contains)
            if (!string.IsNullOrWhiteSpace(filter.Search))
            {
                var search = filter.Search.Trim().ToLower();
                query = query.Where(c => c.Name.ToLower().Contains(search));
            }

            return query;
        }

        protected override async Task BeforeCreateAsync(SupplementCategory entity, CreateCategoryDTO dto)
        {
            if (string.IsNullOrEmpty(dto.Name))
                throw new ArgumentException("Supplement category name cannot be empty.");
        }
        protected override async Task BeforeUpdateAsync(SupplementCategory entity, UpdateCategoriesDTO dto)
        {
            if (string.IsNullOrEmpty(dto.Name))
                throw new ArgumentException("Supplement category name cannot be empty.");
        }

        protected override async Task BeforeDeleteAsync(SupplementCategory entity)
        {
            if (string.IsNullOrEmpty(entity.Name))
                throw new ArgumentException("Supplement category name cannot be empty.");
        }

    }
}

