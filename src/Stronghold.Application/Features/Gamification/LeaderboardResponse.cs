namespace Stronghold.Application.Features.Gamification;

public class LeaderboardResponse
{
    public int Rank { get; set; }
    public int UserId { get; set; }
    public string FullName { get; set; } = string.Empty;
    public string Username { get; set; } = string.Empty;
    public string? ProfileImageUrl { get; set; }
    public int XP { get; set; }
    public int Level { get; set; }
    public string LevelName { get; set; } = string.Empty;
    public int TotalGymMinutes { get; set; }
}
