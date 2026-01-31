namespace Stronghold.Application.DTOs.UserProgressDTO;

public class UserProgressDTO
{
    public int UserId { get; set; }
    public string FullName { get; set; } = string.Empty;
    public int Level { get; set; }
    public int CurrentXP { get; set; }
    public int XPForNextLevel { get; set; } = 2500;
    public int XPProgress { get; set; }
    public double ProgressPercentage { get; set; }
    public int TotalGymMinutesThisWeek { get; set; }
    public List<WeeklyVisitDTO> WeeklyVisits { get; set; } = new();
}
