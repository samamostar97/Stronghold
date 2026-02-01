using Microsoft.EntityFrameworkCore;
using Stronghold.Application.DTOs.UserDTOs;
using Stronghold.Application.IRepositories;
using Stronghold.Application.IServices;
using Stronghold.Core.Entities;
using Stronghold.Core.Exceptions;

namespace Stronghold.Infrastructure.Services
{
    public class UserReviewService:IUserReviewService
    {
        private readonly IRepository<Review, int> _reviewRepository;
        private readonly IRepository<Order, int> _orderRepository;

        public UserReviewService(IRepository<Review, int> reviewRepository, IRepository<Order, int> orderRepository)
        {
            _reviewRepository = reviewRepository;
            _orderRepository = orderRepository;
        }

        public async Task<IEnumerable<UserReviewsDTO>> GetReviewList(int userId)
        {
            var resultList = _reviewRepository.AsQueryable().Where(x => x.UserId == userId).Include(x => x.Supplement);
            var resultListDTO = await resultList.Select(x => new UserReviewsDTO()
            {
                Id = x.Id,
                SupplementName=x.Supplement.Name,
                Rating=x.Rating,
                Comment=x.Comment
            }).ToListAsync();
            return resultListDTO;
        }
        public async Task DeleteReviewAsync(int userId,int reviewId)
        {
            var review = await _reviewRepository.AsQueryable().Where(x => x.UserId == userId && x.Id == reviewId).FirstOrDefaultAsync();
            if (review == null) throw new KeyNotFoundException("Recenzija ne postoji");
            review.IsDeleted = true;
            await _reviewRepository.UpdateAsync(review);
        }

        public async Task<IEnumerable<PurchasedSupplementDTO>> GetPurchasedSupplementsForReviewAsync(int userId)
        {
            var purchasedSupplementIds = await _orderRepository.AsQueryable()
                .Where(o => o.UserId == userId && o.Status == Stronghold.Core.Enums.OrderStatus.Delivered)
                .SelectMany(o => o.OrderItems)
                .Select(oi => oi.SupplementId)
                .Distinct()
                .ToListAsync();

            var reviewedSupplementIds = await _reviewRepository.AsQueryable()
                .Where(r => r.UserId == userId&&!r.IsDeleted)
                .Select(r => r.SupplementId)
                .ToListAsync();

            var availableSupplementIds = purchasedSupplementIds.Except(reviewedSupplementIds).ToList();

            var supplements = await _orderRepository.AsQueryable()
                .Where(o => o.UserId == userId && o.Status == Stronghold.Core.Enums.OrderStatus.Delivered)
                .SelectMany(o => o.OrderItems)
                .Where(oi => availableSupplementIds.Contains(oi.SupplementId))
                .Select(oi => new PurchasedSupplementDTO
                {
                    Id = oi.SupplementId,
                    Name = oi.Supplement.Name
                })
                .Distinct()
                .ToListAsync();

            return supplements;
        }

        public async Task CreateReviewAsync(int userId, CreateReviewRequestDTO dto)
        {
            if (dto.Rating < 1 || dto.Rating > 5)
                throw new ArgumentException("Ocjena mora biti izmedju 1 i 5");

            var hasPurchased = await _orderRepository.AsQueryable()
                .Where(o => o.UserId == userId && o.Status == Stronghold.Core.Enums.OrderStatus.Delivered)
                .SelectMany(o => o.OrderItems)
                .AnyAsync(oi => oi.SupplementId == dto.SupplementId);

            if (!hasPurchased)
                throw new InvalidOperationException("Mozete recenzirati samo kupljene suplemente");

            var alreadyReviewed = await _reviewRepository.AsQueryable()
                .AnyAsync(r => r.UserId == userId && r.SupplementId == dto.SupplementId);

            if (alreadyReviewed)
                throw new InvalidOperationException("Vec ste ostavili recenziju za ovaj suplement");

            var review = new Review
            {
                UserId = userId,
                SupplementId = dto.SupplementId,
                Rating = dto.Rating,
                Comment = dto.Comment
            };

            try
            {
                await _reviewRepository.AddAsync(review);
            }
            catch (DbUpdateException)
            {
                throw new ConflictException("Vec ste ostavili recenziju za ovaj suplement.");
            }
        }
    }
}
