using Stronghold.Domain.Entities;

namespace Stronghold.Application.Interfaces;

public interface IProductRepository : IRepository<Product>
{
    Task<Product?> GetByIdWithDetailsAsync(int id);
}
