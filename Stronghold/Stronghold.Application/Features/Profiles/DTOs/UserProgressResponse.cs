namespace Stronghold.Application.Features.Profiles.DTOs
{
    public class UserProgressResponse
    {
        public int UserId { get; set; }

public string FullName { get; set; } = string.Empty;
        public int Level { get; set; }

public int CurrentXP { get; set; }

public int XPForNextLevel { get; set; } = 2500;
        public int XPProgress { get; set; }

public double ProgressPercentage { get; set; }

public int TotalGymMinutesThisWeek { get; set; }

public List<WeeklyVisitResponse> WeeklyVisits { get; set; } = new();
    }

public class WeeklyVisitResponse
    {
        public DateTime Date { get; set; }

public int Minutes { get; set; }

public string DayName { get; set; } = string.Empty;
    }
    }