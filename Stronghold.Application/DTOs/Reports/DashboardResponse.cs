namespace Stronghold.Application.DTOs.Reports;

/// <summary>Pocetni ekran desktop aplikacije.</summary>
public class DashboardResponse
{
    public int ActiveMembers { get; set; }
    public int VisitsToday { get; set; }
    public int CurrentlyInGym { get; set; }
    public decimal RevenueThisMonth { get; set; }
    public int NewOrdersCount { get; set; }
    public List<DashboardOrder> LatestOrders { get; set; } = new();
    public List<LowStockSupplement> LowStockSupplements { get; set; } = new();
    public int LowStockCount { get; set; }
    public List<ExpiringMembership> ExpiringMemberships { get; set; } = new();
    public int ExpiringMembershipsCount { get; set; }
    public List<DashboardOrder> StuckOrders { get; set; } = new();
    public int StuckOrdersCount { get; set; }
}

public class DashboardOrder
{
    public int Id { get; set; }
    public string UserFullName { get; set; } = null!;
    public DateTime CreatedAt { get; set; }
    public decimal TotalAmount { get; set; }
    public string Status { get; set; } = null!;

    /// <summary>Narudzba koju jos niko nije ni taknuo (nema promjene statusa).</summary>
    public bool IsNew { get; set; }
}

public class LowStockSupplement
{
    public string Name { get; set; } = null!;
    public int StockQuantity { get; set; }
}

public class ExpiringMembership
{
    public string UserFullName { get; set; } = null!;
    public string PackageName { get; set; } = null!;
    public DateTime EndDate { get; set; }
}
