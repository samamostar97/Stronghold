namespace Stronghold.Application.Features.Gamification;

public class GamificationResponse
{
    public int Level { get; set; }
    public string LevelName { get; set; } = string.Empty;
    public int XP { get; set; }
    public int XpToNextLevel { get; set; }
    public int Rank { get; set; }
    public int TotalGymMinutes { get; set; }
    public string? BadgeImageUrl { get; set; }
}
