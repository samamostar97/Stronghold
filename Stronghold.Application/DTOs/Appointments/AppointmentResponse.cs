namespace Stronghold.Application.DTOs.Appointments;

public class AppointmentResponse
{
    public int Id { get; set; }
    public int UserId { get; set; }
    public string UserFullName { get; set; } = null!;
    public int StaffMemberId { get; set; }
    public string StaffFullName { get; set; } = null!;
    public string StaffType { get; set; } = null!;
    public DateOnly Date { get; set; }
    public int StartHour { get; set; }
    public string Status { get; set; } = null!;
    public DateTime CreatedAt { get; set; }
    public DateTime? StatusChangedAt { get; set; }
    public string? CancelledBy { get; set; }
    public string? CancellationReason { get; set; }
}
