using Microsoft.EntityFrameworkCore;
using Stronghold.Application.Interfaces;
using Stronghold.Domain.Entities;
using Stronghold.Infrastructure.Persistence;

namespace Stronghold.Infrastructure.Repositories;

public class CartItemRepository : Repository<CartItem>, ICartItemRepository
{
    public CartItemRepository(StrongholdDbContext context) : base(context) { }

    public async Task<List<CartItem>> GetByUserIdAsync(int userId)
    {
        return await QueryAll()
            .Include(c => c.Product)
            .Where(c => c.UserId == userId)
            .ToListAsync();
    }

    public async Task<CartItem?> GetByUserAndProductAsync(int userId, int productId)
    {
        return await _dbSet.FirstOrDefaultAsync(c => c.UserId == userId && c.ProductId == productId);
    }

    public async Task ClearCartAsync(int userId)
    {
        var items = await _dbSet.Where(c => c.UserId == userId).ToListAsync();
        _dbSet.RemoveRange(items);
    }

    public void HardRemove(CartItem entity)
    {
        _dbSet.Remove(entity);
    }
}
