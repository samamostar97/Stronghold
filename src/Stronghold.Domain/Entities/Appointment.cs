using Stronghold.Domain.Enums;

namespace Stronghold.Domain.Entities;

public class Appointment : BaseEntity
{
    public int UserId { get; set; }
    public User User { get; set; } = null!;
    public int StaffId { get; set; }
    public Staff Staff { get; set; } = null!;
    public DateTime ScheduledAt { get; set; }
    public int DurationMinutes { get; set; } = 60;
    public AppointmentStatus Status { get; set; } = AppointmentStatus.Pending;
    public string? Notes { get; set; }
}
