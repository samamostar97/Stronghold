namespace Stronghold.Application.DTOs.Progress;

public class ProgressResponse
{
    public int Xp { get; set; }
    public int Level { get; set; }
    public int LevelProgressPercent { get; set; }
    public int TotalVisits { get; set; }
    /// <summary>Minute treniranja u zadnjih 30 dana.</summary>
    public int MonthlyMinutes { get; set; }
    /// <summary>Broj posjeta po danu u sedmici (indeks 0 = ponedjeljak).</summary>
    public int[] VisitsByWeekday { get; set; } = new int[7];
    /// <summary>Posjete po sedmicama za zadnjih 8 sedmica (za grafikon).</summary>
    public List<WeeklyVisits> WeeklyVisits { get; set; } = new();
}

public class WeeklyVisits
{
    public DateTime WeekStart { get; set; }
    public int Count { get; set; }
}
