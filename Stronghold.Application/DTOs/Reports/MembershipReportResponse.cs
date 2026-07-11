namespace Stronghold.Application.DTOs.Reports;

// Tab "Clanarine" - aktivni clanovi, stopa obnove, paketi i posjecenost.
public class MembershipReportResponse
{
    public int ActiveCount { get; set; }
    public int ExpiringIn7Days { get; set; }
    public int NewMembersThisMonth { get; set; }

    // Procenat clanarina isteklih u zadnjih 90 dana koje su obnovljene u roku 7 dana.
    public double RenewalRatePercent { get; set; }

    public List<PackageStat> Packages { get; set; } = new();
    public List<WeeklyVisitCount> WeeklyVisits { get; set; } = new();
    public List<HourlyVisitCount> VisitsByHour { get; set; } = new();

    // Prosjecno trajanje zatvorene posjete u zadnjih 30 dana, u minutama.
    public double AvgVisitDurationMinutes { get; set; }

    // Prosjecan broj posjeta po aktivnom clanu u zadnjih 30 dana.
    public double AvgVisitsPerActiveMember { get; set; }
}

// Objedinjena statistika paketa - aktivne clanarine, prodaja i prihod.
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
