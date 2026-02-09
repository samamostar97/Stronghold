using Stronghold.Application.DTOs.Response;

namespace Stronghold.Application.IServices
{
    public interface INotificationService
    {
        Task<int> GetUnreadCountAsync();
        Task<List<NotificationResponse>> GetRecentAsync(int count = 20);
        Task MarkAsReadAsync(int id);
        Task MarkAllAsReadAsync();
        Task CreateAsync(string type, string title, string message, int? relatedEntityId = null, string? relatedEntityType = null);
    }
}
