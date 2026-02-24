using Stronghold.Application.Common;
using Stronghold.Application.Features.Suppliers.DTOs;
using Stronghold.Core.Entities;

namespace Stronghold.Application.IRepositories;

public interface ISupplierRepository
{
    Task<PagedResult<Supplier>> GetPagedAsync(
        SupplierFilter filter,
        CancellationToken cancellationToken = default);
    Task<Supplier?> GetByIdAsync(int id, CancellationToken cancellationToken = default);
    Task<bool> ExistsByNameAsync(string name, int? excludeId = null, CancellationToken cancellationToken = default);
    Task<bool> HasSupplementsAsync(int supplierId, CancellationToken cancellationToken = default);
    Task AddAsync(Supplier entity, CancellationToken cancellationToken = default);
    Task UpdateAsync(Supplier entity, CancellationToken cancellationToken = default);
    Task DeleteAsync(Supplier entity, CancellationToken cancellationToken = default);
}
