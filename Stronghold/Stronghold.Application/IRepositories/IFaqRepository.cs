using Stronghold.Application.Common;
using Stronghold.Application.Features.Faqs.DTOs;
using Stronghold.Core.Entities;

namespace Stronghold.Application.IRepositories;

public interface IFaqRepository
{
    Task<PagedResult<FAQ>> GetPagedAsync(FaqFilter filter, CancellationToken cancellationToken = default);
    Task<FAQ?> GetByIdAsync(int id, CancellationToken cancellationToken = default);
    Task AddAsync(FAQ entity, CancellationToken cancellationToken = default);
    Task UpdateAsync(FAQ entity, CancellationToken cancellationToken = default);
    Task DeleteAsync(FAQ entity, CancellationToken cancellationToken = default);
}
