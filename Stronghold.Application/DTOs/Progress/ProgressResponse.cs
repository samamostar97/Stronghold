namespace Stronghold.Application.DTOs.Progress;

public class ProgressResponse
{
    public int Xp { get; set; }
    public int Level { get; set; }
    public int LevelProgressPercent { get; set; }
    public int TotalVisits { get; set; }
    // Minute treniranja u zadnjih 30 dana.
    public int MonthlyMinutes { get; set; }
    // Broj posjeta po danu u sedmici (indeks 0 = ponedjeljak).
    public int[] VisitsByWeekday { get; set; } = new int[7];
    // Posjete po sedmicama za zadnjih 8 sedmica (za grafikon).
    public List<WeeklyVisits> WeeklyVisits { get; set; } = new();
}

public class WeeklyVisits
{
    public DateTime WeekStart { get; set; }
    public int Count { get; set; }
}
