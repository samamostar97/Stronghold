using Stronghold.Application.Common;
using Stronghold.Application.DTOs.Request;
using Stronghold.Application.DTOs.Response;
using Stronghold.Application.Filters;
using Stronghold.Core.Entities;

namespace Stronghold.Application.IServices
{
    public interface IReviewService : IService<Review, ReviewResponse, CreateReviewRequest, UpdateReviewRequest, ReviewQueryFilter, int>
    {
        // User methods (ownership-based)
        Task<PagedResult<UserReviewResponse>> GetReviewsByUserIdAsync(int userId, ReviewQueryFilter filter);
        Task<PagedResult<PurchasedSupplementResponse>> GetPurchasedSupplementsForReviewAsync(int userId, ReviewQueryFilter filter);
        Task<bool> IsOwnerAsync(int reviewId, int userId);
    }
}
