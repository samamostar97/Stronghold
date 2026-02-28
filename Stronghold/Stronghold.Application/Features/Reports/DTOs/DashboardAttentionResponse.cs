namespace Stronghold.Application.Features.Reports.DTOs;

public class DashboardAttentionResponse
{
    public int PendingOrdersCount { get; set; }
    public int ExpiringMembershipsCount { get; set; }
    public int WindowDays { get; set; } = 7;
}
