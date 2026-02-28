namespace Stronghold.Application.Features.Reports.DTOs;

public class DashboardSalesResponse
{
    public List<DailySalesResponse> DailySales { get; set; } = new();
    public decimal TotalRevenue { get; set; }
    public int TotalOrders { get; set; }
}
