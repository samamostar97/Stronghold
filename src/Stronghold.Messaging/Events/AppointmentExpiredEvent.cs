namespace Stronghold.Messaging.Events;

public class AppointmentExpiredEvent
{
    public string Email { get; set; } = default!;
    public string FirstName { get; set; } = default!;
    public string StaffName { get; set; } = default!;
    public DateTime ScheduledAt { get; set; }
}
