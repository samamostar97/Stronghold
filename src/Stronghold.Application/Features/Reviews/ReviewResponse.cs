namespace Stronghold.Application.Features.Reviews;

public class ReviewResponse
{
    public int Id { get; set; }
    public int UserId { get; set; }
    public string UserName { get; set; } = string.Empty;
    public int Rating { get; set; }
    public string? Comment { get; set; }
    public string ReviewType { get; set; } = string.Empty;
    public int? ProductId { get; set; }
    public int? AppointmentId { get; set; }
    public DateTime CreatedAt { get; set; }
}
