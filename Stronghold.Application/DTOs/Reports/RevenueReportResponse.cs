namespace Stronghold.Application.DTOs.Reports;

/// <summary>Tab "Prihodi" - poslovanje za odabrani period (od mjeseca do mjeseca).</summary>
public class RevenueReportResponse
{
    public int FromYear { get; set; }
    public int FromMonth { get; set; }
    public int ToYear { get; set; }
    public int ToMonth { get; set; }

    public decimal TotalRevenue { get; set; }
    public decimal MembershipRevenue { get; set; }
    public decimal OrderRevenue { get; set; }

    /// <summary>Korisnici cija prva clanarina pocinje u periodu.</summary>
    public int NewMembers { get; set; }

    public int VisitCount { get; set; }

    public List<MonthlyRevenue> MonthlyRevenue { get; set; } = new();
    public List<TopProduct> TopProducts { get; set; } = new();
    public List<PackageSales> PackageSales { get; set; } = new();
}

public class MonthlyRevenue
{
    public int Year { get; set; }
    public int Month { get; set; }
    public decimal MembershipRevenue { get; set; }
    public decimal OrderRevenue { get; set; }
}

public class TopProduct
{
    public string Name { get; set; } = null!;
    public string CategoryName { get; set; } = null!;
    public int QuantitySold { get; set; }
    public decimal Revenue { get; set; }
}

/// <summary>Prodaja clanarina po paketu u periodu.</summary>
public class PackageSales
{
    public string PackageName { get; set; } = null!;
    public int SoldCount { get; set; }
    public decimal Revenue { get; set; }
}
