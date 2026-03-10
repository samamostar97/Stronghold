using Stronghold.Application.Interfaces;
using Stronghold.Domain.Entities;
using Stronghold.Domain.Enums;

namespace Stronghold.Infrastructure.Services;

public class NotificationService : INotificationService
{
    private readonly INotificationRepository _notificationRepository;

    public NotificationService(INotificationRepository notificationRepository)
    {
        _notificationRepository = notificationRepository;
    }

    public async Task CreateOrderNotificationAsync(int orderId)
    {
        var notification = new Notification
        {
            Title = "Nova narudžba",
            Message = $"Nova narudžba #{orderId} je kreirana.",
            Type = NotificationType.NewOrder,
            ReferenceId = orderId
        };

        await _notificationRepository.AddAsync(notification);
        await _notificationRepository.SaveChangesAsync();
    }

    public async Task CreateAppointmentNotificationAsync(int appointmentId, string userName, string staffName)
    {
        var notification = new Notification
        {
            Title = "Nova rezervacija",
            Message = $"Korisnik {userName} je zakazao termin sa {staffName}.",
            Type = NotificationType.NewAppointment,
            ReferenceId = appointmentId
        };

        await _notificationRepository.AddAsync(notification);
        await _notificationRepository.SaveChangesAsync();
    }
}
