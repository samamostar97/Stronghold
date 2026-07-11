namespace Stronghold.Application.DTOs.Reports;

// Tab "Prihodi" - KPI, prihodi po mjesecima, top proizvodi i prihod po kategorijama.
public class RevenueReportResponse
{
    public decimal RevenueThisMonth { get; set; }
    public decimal RevenueLast6Months { get; set; }

    // Prosjecna vrijednost narudzbe u zadnjih 6 mjeseci (bez otkazanih).
    public decimal AvgOrderValue6M { get; set; }

    // Procenat otkazanih narudzbi u zadnjih 6 mjeseci.
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

    // Udio u ukupnom prihodu prodavnice, u procentima.
    public double RevenueShare { get; set; }

    // Prosjecna ocjena; null ako proizvod nema recenzija.
    public double? AverageRating { get; set; }
}

public class CategoryRevenue
{
    public string CategoryName { get; set; } = null!;
    public int QuantitySold { get; set; }
    public decimal Revenue { get; set; }

    // Udio u prihodu prodavnice zadnjih 6 mjeseci, u procentima.
    public double RevenueShare { get; set; }
}
