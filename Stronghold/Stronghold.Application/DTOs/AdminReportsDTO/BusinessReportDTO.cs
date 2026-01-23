using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Stronghold.Application.DTOs.AdminReportsDTO
{
    public class BusinessReportDTO
    {
        public int ThisWeekVisits { get; set; }
        public int LastWeekVisits { get; set; }
        public decimal WeekChangePct { get; set; }
        public decimal ThisMonthRevenue { get; set; }
        public decimal LastMonthRevenue { get; set; }
        public decimal MonthChangePct { get; set; }
        public int ActiveMemberships { get; set; }
        public List<WeekdayVisitsDTO> VisitsByWeekday { get; set; } = new();
        public BestSellerDTO? BestsellerLast30Days { get; set; }
    }
}
