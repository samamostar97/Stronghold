namespace Stronghold.Core.Entities;

public class Seminar : BaseEntity
{
    public string Topic { get; set; } = string.Empty;
    public string SpeakerName { get; set; } = string.Empty;
    public DateTime EventDate { get; set; }

    // Navigation property
    public ICollection<SeminarAttendee> SeminarAttendees { get; set; } = new List<SeminarAttendee>();
}
