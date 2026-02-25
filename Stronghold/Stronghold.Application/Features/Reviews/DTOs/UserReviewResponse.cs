namespace Stronghold.Application.Features.Reviews.DTOs;

public class UserReviewResponse
{
    public int Id { get; set; }

public string SupplementName { get; set; } = string.Empty;
    public int Rating { get; set; }

public string? Comment { get; set; }

public DateTime CreatedAt { get; set; }
}
