using Stronghold.Domain.Entities;

namespace Stronghold.Application.Interfaces;

public interface INotificationRepository
{
    Task<Notification?> GetByIdAsync(int id);
    IQueryable<Notification> Query();
    Task AddAsync(Notification notification);
    Task<int> GetUnreadCountAsync();
    Task MarkAllAsReadAsync();
    Task SaveChangesAsync();
}
