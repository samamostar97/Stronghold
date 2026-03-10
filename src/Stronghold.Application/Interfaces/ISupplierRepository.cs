using Stronghold.Domain.Entities;

namespace Stronghold.Application.Interfaces;

public interface ISupplierRepository : IRepository<Supplier>
{
    Task<Supplier?> GetByEmailAsync(string email);
}
