using Stronghold.Domain.Entities;

namespace Stronghold.Application.Interfaces;

public interface IWishlistItemRepository : IRepository<WishlistItem>
{
    Task<List<WishlistItem>> GetByUserIdAsync(int userId);
    Task<WishlistItem?> GetByUserAndProductAsync(int userId, int productId);
    void HardRemove(WishlistItem entity);
}
