using Microsoft.EntityFrameworkCore;
using Stronghold.Application.Common;
using Stronghold.Application.DTOs.UserDTOs;
using Stronghold.Application.IRepositories;
using Stronghold.Application.IServices;
using Stronghold.Core.Entities;

namespace Stronghold.Infrastructure.Services
{
    public class UserSupplementService : IUserSupplementService
    {
        private readonly IRepository<Supplement, int> _supplementRepository;
        private readonly IRepository<SupplementCategory, int> _categoryRepository;
        private readonly IRepository<Review, int> _reviewRepository;

        public UserSupplementService(
            IRepository<Supplement, int> supplementRepository,
            IRepository<SupplementCategory, int> categoryRepository,
            IRepository<Review, int> reviewRepository)
        {
            _supplementRepository = supplementRepository;
            _categoryRepository = categoryRepository;
            _reviewRepository = reviewRepository;
        }

        public async Task<PagedResult<UserSupplementDTO>> GetSupplementsPaged(PaginationRequest pagination, string? search, int? categoryId)
        {
            var query = _supplementRepository.AsQueryable()
                .Include(s => s.SupplementCategory)
                .AsQueryable();

            if (!string.IsNullOrEmpty(search))
                query = query.Where(s => s.Name.ToLower().Contains(search.ToLower()));

            if (categoryId.HasValue)
                query = query.Where(s => s.SupplementCategoryId == categoryId.Value);

            query = query.OrderBy(s => s.Name);

            var totalCount = await query.CountAsync();
            var items = await query
                .Skip((pagination.PageNumber - 1) * pagination.PageSize)
                .Take(pagination.PageSize)
                .Select(s => new UserSupplementDTO
                {
                    Id = s.Id,
                    Name = s.Name,
                    Price = s.Price,
                    Description = s.Description,
                    ImageUrl = s.SupplementImageUrl,
                    CategoryId = s.SupplementCategoryId,
                    CategoryName = s.SupplementCategory != null ? s.SupplementCategory.Name : "Nepoznato"
                })
                .ToListAsync();

            return new PagedResult<UserSupplementDTO>
            {
                Items = items,
                TotalCount = totalCount,
                PageNumber = pagination.PageNumber
            };
        }

        public async Task<UserSupplementDTO> GetById(int id)
        {
            var supplement = await _supplementRepository.AsQueryable()
                .Include(s => s.SupplementCategory)
                .FirstOrDefaultAsync(s => s.Id == id);

            if (supplement == null)
                throw new InvalidOperationException($"Suplement sa id '{id}' ne postoji.");

            return new UserSupplementDTO
            {
                Id = supplement.Id,
                Name = supplement.Name,
                Price = supplement.Price,
                Description = supplement.Description,
                ImageUrl = supplement.SupplementImageUrl,
                CategoryId = supplement.SupplementCategoryId,
                CategoryName = supplement.SupplementCategory?.Name ?? "Nepoznato"
            };
        }

        public async Task<IEnumerable<UserSupplementCategoryDTO>> GetCategories()
        {
            var categories = await _categoryRepository.AsQueryable()
                .OrderBy(c => c.Name)
                .Select(c => new UserSupplementCategoryDTO
                {
                    Id = c.Id,
                    Name = c.Name
                })
                .ToListAsync();

            return categories;
        }

        public async Task<IEnumerable<SupplementReviewDTO>> GetReviewsBySupplementId(int supplementId)
        {
            var reviews = await _reviewRepository.AsQueryable()
                .Include(r => r.User)
                .Where(r => r.SupplementId == supplementId)
                .OrderByDescending(r => r.CreatedAt)
                .Select(r => new SupplementReviewDTO
                {
                    Id = r.Id,
                    UserName = r.User.FirstName + " " + r.User.LastName.Substring(0, 1) + ".",
                    Rating = r.Rating,
                    Comment = r.Comment,
                    CreatedAt = r.CreatedAt
                })
                .ToListAsync();

            return reviews;
        }
    }
}
