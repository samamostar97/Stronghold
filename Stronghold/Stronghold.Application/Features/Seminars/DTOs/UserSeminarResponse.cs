namespace Stronghold.Application.Features.Seminars.DTOs;

public class UserSeminarResponse
{
    public int Id { get; set; }

public string Topic { get; set; } = string.Empty;
    public string SpeakerName { get; set; } = string.Empty;
    public DateTime EventDate { get; set; }

public bool IsAttending { get; set; }

public int MaxCapacity { get; set; }

public int CurrentAttendees { get; set; }

public bool IsFull { get; set; }

public bool IsCancelled { get; set; }

public string Status { get; set; } = "active";
}
