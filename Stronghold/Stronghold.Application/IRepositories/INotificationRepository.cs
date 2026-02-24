using Stronghold.Core.Entities;

namespace Stronghold.Application.IRepositories;

public interface INotificationRepository
{
    Task<int> GetAdminUnreadCountAsync(CancellationToken cancellationToken = default);
    Task<IReadOnlyList<Notification>> GetRecentAdminAsync(int count, CancellationToken cancellationToken = default);
    Task<Notification?> GetAdminByIdAsync(int id, CancellationToken cancellationToken = default);
    Task<int> GetUserUnreadCountAsync(int userId, CancellationToken cancellationToken = default);
    Task<IReadOnlyList<Notification>> GetRecentForUserAsync(
        int userId,
        int count,
        CancellationToken cancellationToken = default);
    Task<Notification?> GetUserByIdAsync(int userId, int notificationId, CancellationToken cancellationToken = default);
    Task MarkAsReadAsync(Notification notification, CancellationToken cancellationToken = default);
    Task MarkAllAdminAsReadAsync(CancellationToken cancellationToken = default);
    Task MarkAllUserAsReadAsync(int userId, CancellationToken cancellationToken = default);
}
