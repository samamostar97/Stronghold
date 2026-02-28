namespace Stronghold.Application.Features.Dashboard.DTOs;

public class ActivityFeedItemResponse
{
    public string Type { get; set; } = string.Empty;
    public string Description { get; set; } = string.Empty;
    public DateTime Timestamp { get; set; }
    public string? UserName { get; set; }
}
