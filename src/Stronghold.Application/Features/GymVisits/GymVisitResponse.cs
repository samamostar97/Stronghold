namespace Stronghold.Application.Features.GymVisits;

public class GymVisitResponse
{
    public int Id { get; set; }
    public int UserId { get; set; }
    public string UserFullName { get; set; } = string.Empty;
    public string Username { get; set; } = string.Empty;
    public DateTime CheckInAt { get; set; }
    public DateTime? CheckOutAt { get; set; }
    public int? DurationMinutes { get; set; }
}
