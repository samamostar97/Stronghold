namespace Stronghold.Application.DTOs.Reports;

/// <summary>Tab "Prihodi" - clanarine + suplementi po mjesecima i najprodavaniji proizvodi.</summary>
public class RevenueReportResponse
{
    public List<MonthlyRevenue> MonthlyRevenue { get; set; } = new();
    public List<TopProduct> TopProducts { get; set; } = new();
    public decimal TotalMembershipRevenue { get; set; }
    public decimal TotalOrderRevenue { get; set; }
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

    /// <summary>Udio u ukupnom prihodu prodavnice, u procentima.</summary>
    public double RevenueShare { get; set; }

    /// <summary>Prosjecna ocjena; null ako proizvod nema recenzija.</summary>
    public double? AverageRating { get; set; }
}
