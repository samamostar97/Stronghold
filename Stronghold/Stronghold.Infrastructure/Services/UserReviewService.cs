using Microsoft.EntityFrameworkCore;
using Stronghold.Application.DTOs.UserDTOs;
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
    public class UserReviewService:IUserReviewService
    {
        private readonly IRepository<Review, int> _reviewRepository;

        public UserReviewService(IRepository<Review, int> reviewRepository)
        {
            _reviewRepository = reviewRepository;
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
    }
}
