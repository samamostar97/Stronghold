namespace Stronghold.Application.Features.Seminars.DTOs;

public class SeminarAttendeeResponse
{
    public int UserId { get; set; }

public string UserName { get; set; } = string.Empty;
    public DateTime RegisteredAt { get; set; }
}
