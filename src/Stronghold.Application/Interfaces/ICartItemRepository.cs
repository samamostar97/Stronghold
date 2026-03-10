using Stronghold.Domain.Entities;

namespace Stronghold.Application.Interfaces;

public interface ICartItemRepository : IRepository<CartItem>
{
    Task<List<CartItem>> GetByUserIdAsync(int userId);
    Task<CartItem?> GetByUserAndProductAsync(int userId, int productId);
    Task ClearCartAsync(int userId);
    void HardRemove(CartItem entity);
}
