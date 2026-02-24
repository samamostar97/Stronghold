using Microsoft.EntityFrameworkCore;
using Stronghold.Application.IRepositories;
using Stronghold.Core.Entities;
using Stronghold.Infrastructure.Data;

namespace Stronghold.Infrastructure.Repositories;

public class NotificationRepository : INotificationRepository
{
    private readonly StrongholdDbContext _context;

    public NotificationRepository(StrongholdDbContext context)
    {
        _context = context;
    }

    public Task<int> GetAdminUnreadCountAsync(CancellationToken cancellationToken = default)
    {
        return _context.Notifications
            .Where(x => !x.IsDeleted && !x.IsRead && x.UserId == null)
            .CountAsync(cancellationToken);
    }

    public async Task<IReadOnlyList<Notification>> GetRecentAdminAsync(
        int count,
        CancellationToken cancellationToken = default)
    {
        return await _context.Notifications
            .Where(x => !x.IsDeleted && x.UserId == null)
            .OrderByDescending(x => x.CreatedAt)
            .ThenByDescending(x => x.Id)
            .Take(count)
            .ToListAsync(cancellationToken);
    }

    public Task<Notification?> GetAdminByIdAsync(int id, CancellationToken cancellationToken = default)
    {
        return _context.Notifications
            .FirstOrDefaultAsync(x => x.Id == id && !x.IsDeleted && x.UserId == null, cancellationToken);
    }

    public Task<int> GetUserUnreadCountAsync(int userId, CancellationToken cancellationToken = default)
    {
        return _context.Notifications
            .Where(x => !x.IsDeleted && !x.IsRead && x.UserId == userId)
            .CountAsync(cancellationToken);
    }

    public async Task<IReadOnlyList<Notification>> GetRecentForUserAsync(
        int userId,
        int count,
        CancellationToken cancellationToken = default)
    {
        return await _context.Notifications
            .Where(x => !x.IsDeleted && x.UserId == userId)
            .OrderByDescending(x => x.CreatedAt)
            .ThenByDescending(x => x.Id)
            .Take(count)
            .ToListAsync(cancellationToken);
    }

    public Task<Notification?> GetUserByIdAsync(
        int userId,
        int notificationId,
        CancellationToken cancellationToken = default)
    {
        return _context.Notifications
            .FirstOrDefaultAsync(
                x => x.Id == notificationId && !x.IsDeleted && x.UserId == userId,
                cancellationToken);
    }

    public async Task MarkAsReadAsync(Notification notification, CancellationToken cancellationToken = default)
    {
        notification.IsRead = true;
        _context.Notifications.Update(notification);
        await _context.SaveChangesAsync(cancellationToken);
    }

    public Task MarkAllAdminAsReadAsync(CancellationToken cancellationToken = default)
    {
        return _context.Notifications
            .Where(x => !x.IsDeleted && !x.IsRead && x.UserId == null)
            .ExecuteUpdateAsync(setters => setters.SetProperty(x => x.IsRead, true), cancellationToken);
    }

    public Task MarkAllUserAsReadAsync(int userId, CancellationToken cancellationToken = default)
    {
        return _context.Notifications
            .Where(x => !x.IsDeleted && !x.IsRead && x.UserId == userId)
            .ExecuteUpdateAsync(setters => setters.SetProperty(x => x.IsRead, true), cancellationToken);
    }
}
