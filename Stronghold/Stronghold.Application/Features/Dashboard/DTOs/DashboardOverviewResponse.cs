using Stronghold.Application.Features.Reports.DTOs;

namespace Stronghold.Application.Features.Dashboard.DTOs;

public class DashboardOverviewResponse
{
    public int ActiveMemberships { get; set; }
    public int ExpiringThisWeekCount { get; set; }
    public int TodayCheckIns { get; set; }
    public List<DailyVisitsResponse> DailyVisits { get; set; } = new();
}
