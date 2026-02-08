using MapsterMapper;
using Microsoft.EntityFrameworkCore;
using Stronghold.Application.Common;
using Stronghold.Application.DTOs.Request;
using Stronghold.Application.DTOs.Response;
using Stronghold.Application.Exceptions;
using Stronghold.Application.Filters;
using Stronghold.Application.IRepositories;
using Stronghold.Application.IServices;
using Stronghold.Core.Entities;
using Stronghold.Core.Enums;

namespace Stronghold.Infrastructure.Services
{
    public class ReviewService : BaseService<Review, ReviewResponse, CreateReviewRequest, UpdateReviewRequest, ReviewQueryFilter, int>, IReviewService
    {
        private readonly IRepository<Order, int> _orderRepository;

        public ReviewService(
            IRepository<Review, int> repository,
            IRepository<Order, int> orderRepository,
            IMapper mapper) : base(repository, mapper)
        {
            _orderRepository = orderRepository;
        }

        protected override IQueryable<Review> ApplyFilter(IQueryable<Review> query, ReviewQueryFilter filter)
        {
            query = query.Include(x => x.User)
                         .Include(x => x.Supplement);

            if (!string.IsNullOrEmpty(filter.Search))
            {
                var search = filter.Search.ToLower();
                query = query.Where(x =>
                    (x.User != null && (x.User.FirstName.ToLower().Contains(search) || x.User.LastName.ToLower().Contains(search)))
                    || (x.Supplement != null && x.Supplement.Name.ToLower().Contains(search)));
            }

            if (!string.IsNullOrEmpty(filter.OrderBy))
            {
                query = filter.OrderBy.ToLower() switch
                {
                    "firstname" => query.OrderBy(x => x.User != null ? x.User.FirstName : string.Empty),
                    "supplement" => query.OrderBy(x => x.Supplement != null ? x.Supplement.Name : string.Empty),
                    "createdatdesc" => query.OrderByDescending(x => x.CreatedAt),
                    _ => query.OrderBy(x => x.CreatedAt)
                };
                return query;
            }

            query = query.OrderBy(x => x.CreatedAt);
            return query;
        }

        protected override async Task BeforeCreateAsync(Review entity, CreateReviewRequest dto)
        {
            if (dto.Rating < 1 || dto.Rating > 5)
                throw new ArgumentException("Ocjena mora biti izmedju 1 i 5");

            var hasPurchased = await _orderRepository.AsQueryable()
                .Where(o => o.UserId == dto.UserId && o.Status == OrderStatus.Delivered)
                .SelectMany(o => o.OrderItems)
                .AnyAsync(oi => oi.SupplementId == dto.SupplementId);

            if (!hasPurchased)
                throw new InvalidOperationException("Mozete recenzirati samo kupljene suplemente");

            var alreadyReviewed = await _repository.AsQueryable()
                .AnyAsync(r => r.UserId == dto.UserId && r.SupplementId == dto.SupplementId);

            if (alreadyReviewed)
                throw new ConflictException("Vec ste ostavili recenziju za ovaj suplement");
        }

        public override Task<ReviewResponse> UpdateAsync(int id, UpdateReviewRequest dto)
        {
            throw new NotSupportedException("Recenzije se ne mogu mijenjati");
        }


        public async Task<PagedResult<UserReviewResponse>> GetReviewsByUserIdAsync(int userId, ReviewQueryFilter filter)
        {
            var query = _repository.AsQueryable()
                .Where(x => x.UserId == userId)
                .Include(x => x.Supplement)
                .OrderByDescending(x => x.CreatedAt);

            var totalCount = await query.CountAsync();

            var reviews = await query
                .Skip((filter.PageNumber - 1) * filter.PageSize)
                .Take(filter.PageSize)
                .ToListAsync();

            var items = reviews.Select(x => new UserReviewResponse
            {
                Id = x.Id,
                SupplementName = x.Supplement.Name,
                Rating = x.Rating,
                Comment = x.Comment
            }).ToList();

            return new PagedResult<UserReviewResponse>
            {
                Items = items,
                TotalCount = totalCount,
                PageNumber = filter.PageNumber
            };
        }

        public async Task<PagedResult<PurchasedSupplementResponse>> GetPurchasedSupplementsForReviewAsync(int userId, ReviewQueryFilter filter)
        {
            // Single query: Get purchased supplements that haven't been reviewed yet
            var query = _orderRepository.AsQueryable()
                .Where(o => o.UserId == userId && o.Status == OrderStatus.Delivered)
                .SelectMany(o => o.OrderItems)
                .Where(oi => !_repository.AsQueryable().Any(r => r.UserId == userId && r.SupplementId == oi.SupplementId))
                .Select(oi => new PurchasedSupplementResponse
                {
                    Id = oi.SupplementId,
                    Name = oi.Supplement.Name
                })
                .Distinct();

            var totalCount = await query.CountAsync();

            var supplements = await query
                .Skip((filter.PageNumber - 1) * filter.PageSize)
                .Take(filter.PageSize)
                .ToListAsync();

            return new PagedResult<PurchasedSupplementResponse>
            {
                Items = supplements,
                TotalCount = totalCount,
                PageNumber = filter.PageNumber
            };
        }

        public async Task<bool> IsOwnerAsync(int reviewId, int userId)
        {
            return await _repository.AsQueryable()
                .AnyAsync(r => r.Id == reviewId && r.UserId == userId);
        }
    }
}
