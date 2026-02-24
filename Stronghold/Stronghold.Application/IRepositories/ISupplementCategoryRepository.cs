using Stronghold.Application.Common;
using Stronghold.Application.Features.SupplementCategories.DTOs;
using Stronghold.Core.Entities;

namespace Stronghold.Application.IRepositories;

public interface ISupplementCategoryRepository
{
    Task<PagedResult<SupplementCategory>> GetPagedAsync(
        SupplementCategoryFilter filter,
        CancellationToken cancellationToken = default);
    Task<SupplementCategory?> GetByIdAsync(int id, CancellationToken cancellationToken = default);
    Task<bool> ExistsByNameAsync(string name, int? excludeId = null, CancellationToken cancellationToken = default);
    Task<bool> HasSupplementsAsync(int supplementCategoryId, CancellationToken cancellationToken = default);
    Task AddAsync(SupplementCategory entity, CancellationToken cancellationToken = default);
    Task UpdateAsync(SupplementCategory entity, CancellationToken cancellationToken = default);
    Task DeleteAsync(SupplementCategory entity, CancellationToken cancellationToken = default);
}
