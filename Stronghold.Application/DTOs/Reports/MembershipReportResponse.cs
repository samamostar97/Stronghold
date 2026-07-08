namespace Stronghold.Application.DTOs.Reports;

/// <summary>Tab "Clanarine" - aktivni clanovi, raspodjela po paketima, posjecenost.</summary>
public class MembershipReportResponse
{
    public int ActiveCount { get; set; }
    public int ExpiringIn7Days { get; set; }
    public int NewMembersThisMonth { get; set; }
    public int RevokedCount { get; set; }
    public List<PackageDistribution> ByPackage { get; set; } = new();
    public List<PackageSales> PackageSales { get; set; } = new();
    public List<WeeklyVisitCount> WeeklyVisits { get; set; } = new();
}

/// <summary>Prodaja clanarina po paketu - broj uplata i prihod.</summary>
public class PackageSales
{
    public string PackageName { get; set; } = null!;
    public int SoldCount { get; set; }
    public int SoldLast6Months { get; set; }
    public decimal Revenue { get; set; }
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
