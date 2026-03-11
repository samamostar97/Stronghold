namespace Stronghold.Application.Features.Dashboard;

public class DashboardStatsResponse
{
    public int ActiveGymVisits { get; set; }
    public int ActiveMemberships { get; set; }
    public int PendingOrders { get; set; }
    public int PendingAppointments { get; set; }
}
