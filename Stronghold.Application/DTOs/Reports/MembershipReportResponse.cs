namespace Stronghold.Application.DTOs.Reports;

/// <summary>Tab "Clanarine" - aktivni clanovi, raspodjela po paketima, posjecenost.</summary>
public class MembershipReportResponse
{
    public int ActiveCount { get; set; }
    public int ExpiringIn7Days { get; set; }
    public List<PackageDistribution> ByPackage { get; set; } = new();
    public List<WeeklyVisitCount> WeeklyVisits { get; set; } = new();
}

public class PackageDistribution
{
    public string PackageName { get; set; } = null!;
    public int ActiveCount { get; set; }
}

public class WeeklyVisitCount
{
    public DateTime WeekStart { get; set; }
    public int Count { get; set; }
}
