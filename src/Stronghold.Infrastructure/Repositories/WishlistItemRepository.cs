using Microsoft.EntityFrameworkCore;
using Stronghold.Application.Interfaces;
using Stronghold.Domain.Entities;
using Stronghold.Infrastructure.Persistence;

namespace Stronghold.Infrastructure.Repositories;

public class WishlistItemRepository : Repository<WishlistItem>, IWishlistItemRepository
{
    public WishlistItemRepository(StrongholdDbContext context) : base(context) { }

    public async Task<List<WishlistItem>> GetByUserIdAsync(int userId)
    {
        return await _dbSet
            .Include(w => w.Product)
            .Where(w => w.UserId == userId)
            .OrderByDescending(w => w.CreatedAt)
            .ToListAsync();
    }

    public async Task<WishlistItem?> GetByUserAndProductAsync(int userId, int productId)
    {
        return await _dbSet.FirstOrDefaultAsync(w => w.UserId == userId && w.ProductId == productId);
    }

    public void HardRemove(WishlistItem entity)
    {
        _dbSet.Remove(entity);
    }
}
