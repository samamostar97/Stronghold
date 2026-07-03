namespace Stronghold.Application.DTOs.Reports;

/// <summary>Pocetni ekran desktop aplikacije.</summary>
public class DashboardResponse
{
    public int ActiveMembers { get; set; }
    public int VisitsToday { get; set; }
    public int CurrentlyInGym { get; set; }
    public decimal RevenueThisMonth { get; set; }
    public List<DashboardOrder> LatestOrders { get; set; } = new();
}

public class DashboardOrder
{
    public int Id { get; set; }
    public string UserFullName { get; set; } = null!;
    public DateTime CreatedAt { get; set; }
    public decimal TotalAmount { get; set; }
    public string Status { get; set; } = null!;
}
