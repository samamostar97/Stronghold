namespace Stronghold.Application.Interfaces;

public interface IEmailService
{
    Task SendWelcomeAsync(string email, string firstName);
    Task SendOrderConfirmedAsync(string email, string firstName, int orderId, decimal totalAmount);
    Task SendOrderShippedAsync(string email, string firstName, int orderId);
    Task SendAppointmentApprovedAsync(string email, string firstName, string staffName, DateTime scheduledAt);
    Task SendAppointmentRejectedAsync(string email, string firstName, string staffName, DateTime scheduledAt);
    Task SendMembershipAssignedAsync(string email, string firstName, string packageName, DateTime endDate);
    Task SendMembershipExpiredAsync(string email, string firstName, string packageName);
    Task SendAppointmentExpiredAsync(string email, string firstName, string staffName, DateTime scheduledAt);
    Task SendLevelUpAsync(string email, string firstName, string levelName);
}
