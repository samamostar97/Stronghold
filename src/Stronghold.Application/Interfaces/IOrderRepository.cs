using Stronghold.Domain.Entities;

namespace Stronghold.Application.Interfaces;

public interface IOrderRepository : IRepository<Order>
{
    Task<Order?> GetByIdWithItemsAsync(int id);
    Task<List<Order>> GetByUserIdAsync(int userId);
}
