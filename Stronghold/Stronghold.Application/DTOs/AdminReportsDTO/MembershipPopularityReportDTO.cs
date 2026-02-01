namespace Stronghold.Application.DTOs.AdminReportsDTO;

public class MembershipPopularityReportDTO
{
    public List<MembershipPlanStatsDTO> PlanStats { get; set; } = new();
    public int TotalActiveMemberships { get; set; }
    public decimal TotalRevenueLast90Days { get; set; }
}

public class MembershipPlanStatsDTO
{
    public int MembershipPackageId { get; set; }
    public string PackageName { get; set; } = string.Empty;
    public decimal PackagePrice { get; set; }
    public int ActiveSubscriptions { get; set; }
    public int NewSubscriptionsLast30Days { get; set; }
    public decimal RevenueLast90Days { get; set; }
    public decimal PopularityPercentage { get; set; }
}
