namespace Stronghold.Application.Interfaces;

public interface INotificationService
{
    Task CreateOrderNotificationAsync(int orderId);
    Task CreateAppointmentNotificationAsync(int appointmentId, string userName, string staffName);
}
