namespace Stronghold.Application.DTOs.Reports;

/// <summary>Tab "Clanarine" - aktivni clanovi, stopa obnove, paketi i posjecenost.</summary>
public class MembershipReportResponse
{
    public int ActiveCount { get; set; }
    public int ExpiringIn7Days { get; set; }
    public int NewMembersThisMonth { get; set; }

    /// <summary>Procenat clanarina isteklih u zadnjih 90 dana koje su obnovljene u roku 7 dana.</summary>
    public double RenewalRatePercent { get; set; }

    public List<PackageStat> Packages { get; set; } = new();
    public List<WeeklyVisitCount> WeeklyVisits { get; set; } = new();
    public List<HourlyVisitCount> VisitsByHour { get; set; } = new();

    /// <summary>Prosjecno trajanje zatvorene posjete u zadnjih 30 dana, u minutama.</summary>
    public double AvgVisitDurationMinutes { get; set; }

    /// <summary>Prosjecan broj posjeta po aktivnom clanu u zadnjih 30 dana.</summary>
    public double AvgVisitsPerActiveMember { get; set; }
}

/// <summary>Objedinjena statistika paketa - aktivne clanarine, prodaja i prihod.</summary>
public class PackageStat
{
    public string PackageName { get; set; } = null!;
    public int ActiveCount { get; set; }
    public int SoldLast6Months { get; set; }
    public decimal Revenue { get; set; }
}

public class WeeklyVisitCount
{
    public DateTime WeekStart { get; set; }
    public int Count { get; set; }
}

public class HourlyVisitCount
{
    public int Hour { get; set; }
    public int Count { get; set; }
}
