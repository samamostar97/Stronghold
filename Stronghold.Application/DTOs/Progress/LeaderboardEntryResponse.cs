namespace Stronghold.Application.DTOs.Progress;

public class LeaderboardEntryResponse
{
    public int Rank { get; set; }
    public int UserId { get; set; }
    public string FullName { get; set; } = null!;
    public string Username { get; set; } = null!;
    public int Xp { get; set; }
    public int Level { get; set; }
    public int VisitCount { get; set; }
    public int TotalHours { get; set; }
}
