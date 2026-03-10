using Microsoft.EntityFrameworkCore;
using Stronghold.Application.Interfaces;
using Stronghold.Domain.Entities;
using Stronghold.Infrastructure.Persistence;

namespace Stronghold.Infrastructure.Repositories;

public class LevelRepository : Repository<Level>, ILevelRepository
{
    public LevelRepository(StrongholdDbContext context) : base(context) { }

    public async Task<Level?> GetByXpAsync(int xp)
    {
        return await _dbSet.FirstOrDefaultAsync(l => xp >= l.MinXP && xp <= l.MaxXP);
    }

    public async Task<List<Level>> GetAllOrderedAsync()
    {
        return await _dbSet.OrderBy(l => l.MinXP).ToListAsync();
    }
}
