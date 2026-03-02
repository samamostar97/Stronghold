using Stronghold.Application.Common;
using Stronghold.Application.Features.Supplements.DTOs;
using Stronghold.Core.Entities;

namespace Stronghold.Application.IRepositories;

public interface ISupplementRepository
{
    Task<PagedResult<Supplement>> GetPagedAsync(
        SupplementFilter filter,
        CancellationToken cancellationToken = default);
    Task<Supplement?> GetByIdAsync(int id, CancellationToken cancellationToken = default);
    Task<bool> ExistsByNameAsync(string name, int? excludeId = null, CancellationToken cancellationToken = default);
    Task<bool> SupplementCategoryExistsAsync(int supplementCategoryId, CancellationToken cancellationToken = default);
    Task<bool> SupplierExistsAsync(int supplierId, CancellationToken cancellationToken = default);
    Task<bool> HasReviewsAsync(int supplementId, CancellationToken cancellationToken = default);
    Task<IReadOnlyList<Review>> GetReviewsAsync(int supplementId, CancellationToken cancellationToken = default);
    Task<IReadOnlyList<Supplement>> GetRecommendationCandidatesAsync(
        IReadOnlyCollection<int> excludedSupplementIds,
        CancellationToken cancellationToken = default);
    Task AddAsync(Supplement entity, CancellationToken cancellationToken = default);
    Task UpdateAsync(Supplement entity, CancellationToken cancellationToken = default);
    Task DeleteAsync(Supplement entity, CancellationToken cancellationToken = default);
    Task AddStockLogAsync(StockLog log, CancellationToken cancellationToken = default);
}
