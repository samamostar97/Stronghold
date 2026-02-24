using Stronghold.Application.Common;
using Stronghold.Application.Features.Reviews.DTOs;
using Stronghold.Core.Entities;

namespace Stronghold.Application.IRepositories;

public interface IReviewRepository
{
    Task<PagedResult<Review>> GetPagedAsync(ReviewFilter filter, CancellationToken cancellationToken = default);
    Task<Review?> GetByIdAsync(int id, CancellationToken cancellationToken = default);
    Task<PagedResult<Review>> GetPagedByUserAsync(
        int userId,
        ReviewFilter filter,
        CancellationToken cancellationToken = default);
    Task<PagedResult<PurchasedSupplementResponse>> GetPurchasedSupplementsForReviewAsync(
        int userId,
        ReviewFilter filter,
        CancellationToken cancellationToken = default);
    Task<bool> ExistsByUserAndSupplementAsync(int userId, int supplementId, CancellationToken cancellationToken = default);
    Task<IReadOnlyList<Review>> GetHighlyRatedByUserAsync(
        int userId,
        int minRating,
        CancellationToken cancellationToken = default);
    Task<bool> HasPurchasedSupplementAsync(int userId, int supplementId, CancellationToken cancellationToken = default);
    Task<bool> SupplementExistsAsync(int supplementId, CancellationToken cancellationToken = default);
    Task<bool> IsOwnerAsync(int reviewId, int userId, CancellationToken cancellationToken = default);
    Task AddAsync(Review entity, CancellationToken cancellationToken = default);
    Task DeleteAsync(Review entity, CancellationToken cancellationToken = default);
}
