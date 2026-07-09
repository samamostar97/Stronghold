namespace Stronghold.Application.DTOs.Reports;

/// <summary>Tab "Prihodi" - KPI, prihodi po mjesecima, top proizvodi i prihod po kategorijama.</summary>
public class RevenueReportResponse
{
    public decimal RevenueThisMonth { get; set; }
    public decimal RevenueLast6Months { get; set; }

    /// <summary>Prosjecna vrijednost narudzbe u zadnjih 6 mjeseci (bez otkazanih).</summary>
    public decimal AvgOrderValue6M { get; set; }

    /// <summary>Procenat otkazanih narudzbi u zadnjih 6 mjeseci.</summary>
    public double OrderCancellationRate6M { get; set; }

    public List<MonthlyRevenue> MonthlyRevenue { get; set; } = new();
    public List<TopProduct> TopProducts { get; set; } = new();
    public List<CategoryRevenue> RevenueByCategory { get; set; } = new();
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

public class CategoryRevenue
{
    public string CategoryName { get; set; } = null!;
    public int QuantitySold { get; set; }
    public decimal Revenue { get; set; }

    /// <summary>Udio u prihodu prodavnice zadnjih 6 mjeseci, u procentima.</summary>
    public double RevenueShare { get; set; }
}
