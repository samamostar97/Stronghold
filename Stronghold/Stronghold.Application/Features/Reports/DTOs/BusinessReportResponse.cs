namespace Stronghold.Application.Features.Reports.DTOs
{
    public class BusinessReportResponse
    {
        public int ThisWeekVisits { get; set; }

public int LastWeekVisits { get; set; }

public decimal WeekChangePct { get; set; }

public decimal ThisMonthRevenue { get; set; }

public decimal LastMonthRevenue { get; set; }

public decimal MonthChangePct { get; set; }

public int ActiveMemberships { get; set; }
        public int ExpiringThisWeekCount { get; set; }
        public int TodayCheckIns { get; set; }
        public int Last30DaysCheckIns { get; set; }
        public decimal AvgDailyCheckIns { get; set; }

public List<WeekdayVisitsResponse> VisitsByWeekday { get; set; } = new();
        public BestSellerResponse? BestsellerLast30Days { get; set; }
        public SlowestMovingResponse? SlowestMovingLast30Days { get; set; }
        public PopularMembershipResponse? PopularMembership { get; set; }
        public int ThisMonthVisits { get; set; }
        public BusiestDayResponse? BusiestDay { get; set; }

public List<DailySalesResponse> DailySales { get; set; } = new();
        public RevenueBreakdownResponse RevenueBreakdown { get; set; } = new();
        public List<HeatmapCellResponse> CheckInHeatmap { get; set; } = new();
        public List<DailyVisitsResponse> DailyVisits { get; set; } = new();
        public MostActivePackageResponse? MostActivePackage { get; set; }
        public GrowthRateResponse GrowthRate { get; set; } = new();
    }

public class WeekdayVisitsResponse
    {
        public DayOfWeek Day { get; set; }

public int Count { get; set; }
    }

public class BestSellerResponse
    {
        public int SupplementId { get; set; }

public string Name { get; set; } = string.Empty;
        public int QuantitySold { get; set; }
    }

public class SlowestMovingResponse
    {
        public int SupplementId { get; set; }
        public string Name { get; set; } = string.Empty;
        public int QuantitySold { get; set; }
        public int DaysSinceLastSale { get; set; }
    }

public class BusiestDayResponse
    {
        public DateTime Date { get; set; }
        public int VisitCount { get; set; }
    }

public class PopularMembershipResponse
    {
        public int MembershipPackageId { get; set; }
        public string PackageName { get; set; } = string.Empty;
        public int PurchaseCount { get; set; }
    }

public class DailySalesResponse
    {
        public DateTime Date { get; set; }

public decimal Revenue { get; set; }

public int OrderCount { get; set; }
    }

public class RevenueBreakdownResponse
    {
        public decimal TodayRevenue { get; set; }

public decimal ThisWeekRevenue { get; set; }

public decimal ThisMonthRevenue { get; set; }

public decimal AverageOrderValue { get; set; }

public int TodayOrderCount { get; set; }

public decimal MonthOrderRevenue { get; set; }
    }

public class HeatmapCellResponse
    {
        public DayOfWeek Day { get; set; }
        public int Hour { get; set; }
        public int Count { get; set; }
    }

public class DailyVisitsResponse
    {
        public DateTime Date { get; set; }
        public int VisitCount { get; set; }
    }

public class MostActivePackageResponse
    {
        public string PackageName { get; set; } = string.Empty;
        public int VisitCount { get; set; }
    }

    public class GrowthRateResponse
    {
        public decimal GrowthPct { get; set; }
        public int PeriodDays { get; set; }
    }

    }