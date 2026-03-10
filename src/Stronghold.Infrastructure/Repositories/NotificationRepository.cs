using Microsoft.EntityFrameworkCore;
using Stronghold.Application.Interfaces;
using Stronghold.Domain.Entities;
using Stronghold.Infrastructure.Persistence;

namespace Stronghold.Infrastructure.Repositories;

public class NotificationRepository : INotificationRepository
{
    private readonly StrongholdDbContext _context;
    private readonly DbSet<Notification> _dbSet;

    public NotificationRepository(StrongholdDbContext context)
    {
        _context = context;
        _dbSet = context.Set<Notification>();
    }

    public async Task<Notification?> GetByIdAsync(int id)
    {
        return await _dbSet.FirstOrDefaultAsync(n => n.Id == id);
    }

    public IQueryable<Notification> Query()
    {
        return _dbSet.AsQueryable();
    }

    public async Task AddAsync(Notification notification)
    {
        await _dbSet.AddAsync(notification);
    }

    public async Task<int> GetUnreadCountAsync()
    {
        return await _dbSet.CountAsync(n => !n.IsRead);
    }

    public async Task MarkAllAsReadAsync()
    {
        await _dbSet.Where(n => !n.IsRead)
            .ExecuteUpdateAsync(s => s.SetProperty(n => n.IsRead, true));
    }

    public async Task SaveChangesAsync()
    {
        await _context.SaveChangesAsync();
    }
}
