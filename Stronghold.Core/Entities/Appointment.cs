using Stronghold.Core.Enums;

namespace Stronghold.Core.Entities;

/// <summary>
/// Termin je fiksni slot od 60 minuta unutar radnog vremena osoblja.
/// </summary>
public class Appointment : BaseEntity
{
    public int UserId { get; set; }
    public User User { get; set; } = null!;
    public int StaffMemberId { get; set; }
    public StaffMember StaffMember { get; set; } = null!;
    public DateOnly Date { get; set; }
    public int StartHour { get; set; }
    public AppointmentStatus Status { get; set; }
    public DateTime CreatedAt { get; set; }
    public DateTime? StatusChangedAt { get; set; }
    public int? StatusChangedByUserId { get; set; }
    public CancellationActor? CancelledBy { get; set; }
    public string? CancellationReason { get; set; }
}
