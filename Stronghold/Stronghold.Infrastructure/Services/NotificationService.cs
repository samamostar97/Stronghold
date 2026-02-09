using Microsoft.EntityFrameworkCore;
using Stronghold.Application.DTOs.Response;
using Stronghold.Application.IServices;
using Stronghold.Core.Entities;
using Stronghold.Infrastructure.Data;

namespace Stronghold.Infrastructure.Services
{
    public class NotificationService : INotificationService
    {
        private readonly StrongholdDbContext _context;

        public NotificationService(StrongholdDbContext context)
        {
            _context = context;
        }

        public async Task<int> GetUnreadCountAsync()
        {
            return await _context.Notifications
                .Where(n => !n.IsRead && !n.IsDeleted)
                .CountAsync();
        }

        public async Task<List<NotificationResponse>> GetRecentAsync(int count = 20)
        {
            var notifications = await _context.Notifications
                .Where(n => !n.IsDeleted)
                .OrderByDescending(n => n.CreatedAt)
                .Take(count)
                .Select(n => new NotificationResponse
                {
                    Id = n.Id,
                    Type = n.Type,
                    Title = n.Title,
                    Message = n.Message,
                    IsRead = n.IsRead,
                    CreatedAt = n.CreatedAt,
                    RelatedEntityId = n.RelatedEntityId,
                    RelatedEntityType = n.RelatedEntityType,
                })
                .ToListAsync();

            return notifications;
        }

        public async Task MarkAsReadAsync(int id)
        {
            var notification = await _context.Notifications.FindAsync(id);
            if (notification == null || notification.IsDeleted) return;

            notification.IsRead = true;
            await _context.SaveChangesAsync();
        }

        public async Task MarkAllAsReadAsync()
        {
            await _context.Notifications
                .Where(n => !n.IsRead && !n.IsDeleted)
                .ExecuteUpdateAsync(s => s.SetProperty(n => n.IsRead, true));
        }

        public async Task CreateAsync(
            string type,
            string title,
            string message,
            int? relatedEntityId = null,
            string? relatedEntityType = null)
        {
            var notification = new Notification
            {
                Type = type,
                Title = title,
                Message = message,
                IsRead = false,
                RelatedEntityId = relatedEntityId,
                RelatedEntityType = relatedEntityType,
                CreatedAt = DateTime.UtcNow,
            };

            _context.Notifications.Add(notification);
            await _context.SaveChangesAsync();
        }
    }
}
