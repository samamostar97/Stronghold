using Stronghold.Application.DTOs.Response;

namespace Stronghold.Application.IServices
{
    public interface INotificationService
    {
        // Admin notifications (UserId = null)
        Task<int> GetUnreadCountAsync();
        Task<List<NotificationResponse>> GetRecentAsync(int count = 20);
        Task MarkAsReadAsync(int id);
        Task MarkAllAsReadAsync();
        Task CreateAsync(string type, string title, string message, int? relatedEntityId = null, string? relatedEntityType = null);

        // User-specific notifications
        Task<int> GetUserUnreadCountAsync(int userId);
        Task<List<NotificationResponse>> GetUserRecentAsync(int userId, int count = 20);
        Task MarkUserNotificationAsReadAsync(int userId, int notificationId);
        Task MarkAllUserNotificationsAsReadAsync(int userId);
        Task CreateForUserAsync(int userId, string type, string title, string message, int? relatedEntityId = null, string? relatedEntityType = null);
    }
}
