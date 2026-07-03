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
    public int QuantitySold { get; set; }
    public decimal Revenue { get; set; }
}
