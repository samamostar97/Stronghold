namespace Stronghold.Application.DTOs.Response
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
        public List<WeekdayVisitsResponse> VisitsByWeekday { get; set; } = new();
        public BestSellerResponse? BestsellerLast30Days { get; set; }
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
}
