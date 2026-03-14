namespace Stronghold.Domain.Entities;

public class GymVisit : BaseEntity
{
    public int UserId { get; set; }
    public User User { get; set; } = null!;
    public string UserFullName { get; set; } = string.Empty;
    public string Username { get; set; } = string.Empty;
    public DateTime CheckInAt { get; set; }
    public DateTime? CheckOutAt { get; set; }
    public int? DurationMinutes { get; set; }
}
