using Stronghold.Domain.Entities;

namespace Stronghold.Application.Features.Notifications;

public static class NotificationMappings
{
    public static NotificationResponse ToResponse(Notification notification)
    {
        return new NotificationResponse
        {
            Id = notification.Id,
            Title = notification.Title,
            Message = notification.Message,
            Type = notification.Type.ToString(),
            ReferenceId = notification.ReferenceId,
            IsRead = notification.IsRead,
            CreatedAt = notification.CreatedAt
        };
    }
}
