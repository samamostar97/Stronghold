namespace Stronghold.Application.Features.Visits.DTOs;

public class VisitResponse
{
    public int Id { get; set; }

public int UserId { get; set; }

public string Username { get; set; } = string.Empty;
    public string FirstName { get; set; } = string.Empty;
    public string LastName { get; set; } = string.Empty;
    public DateTime CheckInTime { get; set; }

public DateTime? CheckOutTime { get; set; }
}
