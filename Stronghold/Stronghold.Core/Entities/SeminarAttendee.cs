namespace Stronghold.Core.Entities;

public class SeminarAttendee : BaseEntity
{
    public int UserId { get; set; }
    public int SeminarId { get; set; }
    public DateTime RegisteredAt { get; set; }

    // Navigation properties
    public User User { get; set; } = null!;
    public Seminar Seminar { get; set; } = null!;
}
