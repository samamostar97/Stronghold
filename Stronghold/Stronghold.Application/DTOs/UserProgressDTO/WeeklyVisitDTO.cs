namespace Stronghold.Application.DTOs.UserProgressDTO;

public class WeeklyVisitDTO
{
    public DateTime Date { get; set; }
    public int Minutes { get; set; }
    public string DayName { get; set; } = string.Empty;
}
