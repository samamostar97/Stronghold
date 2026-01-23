using Microsoft.EntityFrameworkCore;
using Stronghold.Application.DTOs.AdminReportsDTO;
using Stronghold.Application.IServices;
using Stronghold.Infrastructure.Data;


namespace Stronghold.Infrastructure.Services
{
    public class ReportService : IReportService
    {
        private readonly StrongholdDbContext _context;

        public ReportService(StrongholdDbContext context)
        {
            _context = context;
        }

        public async Task<BusinessReportDTO> GetBusinessReportAsync()
        {
            var now = DateTime.UtcNow;

            // Week boundaries (UTC)
            var startOfWeek = GetStartOfWeekUtc(now);
            var startOfNextWeek = startOfWeek.AddDays(7);
            var lastWeekStart = startOfWeek.AddDays(-7);

            // Month boundaries (UTC)
            var startOfMonth = new DateTime(now.Year, now.Month, 1, 0, 0, 0, DateTimeKind.Utc);
            var startOfNextMonth = startOfMonth.AddMonths(1);
            var startOfLastMonth = startOfMonth.AddMonths(-1);

            // Weekly visits
            var thisWeekVisits = await _context.GymVisits
                .AsNoTracking()
                .Where(v => v.CheckInTime >= startOfWeek && v.CheckInTime < startOfNextWeek)
                .CountAsync();

            var lastWeekVisits = await _context.GymVisits
                .AsNoTracking()
                .Where(v => v.CheckInTime >= lastWeekStart && v.CheckInTime < startOfWeek)
                .CountAsync();

            // Monthly revenue 

            var thisMonthRevenue = await _context.MembershipPaymentHistory
                .AsNoTracking()
                .Where(p => p.PaymentDate >= startOfMonth && p.PaymentDate < startOfNextMonth)
                .SumAsync(p => (decimal?)p.AmountPaid) ?? 0m;

            var lastMonthRevenue = await _context.MembershipPaymentHistory
                .AsNoTracking()
                .Where(p => p.PaymentDate >= startOfLastMonth && p.PaymentDate < startOfMonth)
                .SumAsync(p => (decimal?)p.AmountPaid) ?? 0m;

            // Active memberships
            var activeMemberships = await _context.Memberships
                .AsNoTracking()
                .Where(m => m.StartDate <= now && m.EndDate >= now)
                .CountAsync();

            // Visits by weekday (current week)
            var visitTimes = await _context.GymVisits
                .AsNoTracking()
                .Where(v => v.CheckInTime >= startOfWeek && v.CheckInTime < startOfNextWeek)
                .Select(v => v.CheckInTime)
                .ToListAsync();

            var rawByDay = visitTimes
                .GroupBy(d => d.DayOfWeek)
                .Select(g => new WeekdayVisitsDTO
                {
                    Day = g.Key,
                    Count = g.Count()
                })
                .ToList();

            var visitsByWeekday = BuildWeekdayVisits(rawByDay);

            // Bestseller (last 30 days)
            var since = now.AddDays(-30);

            var bestseller = await _context.OrderItems
                .AsNoTracking()
                .Where(oi => oi.Order.PurchaseDate >= since && oi.Order.PurchaseDate <= now)
                .GroupBy(oi => new { oi.SupplementId, oi.Supplement.Name })
                .Select(g => new
                {
                    g.Key.SupplementId,
                    g.Key.Name,
                    Quantity = g.Sum(x => x.Quantity)
                })
                .OrderByDescending(x => x.Quantity)
                .FirstOrDefaultAsync();

            return new BusinessReportDTO
            {
                ThisWeekVisits = thisWeekVisits,
                LastWeekVisits = lastWeekVisits,
                WeekChangePct = CalculateChangePct(thisWeekVisits, lastWeekVisits),

                ThisMonthRevenue = thisMonthRevenue,
                LastMonthRevenue = lastMonthRevenue,
                MonthChangePct = CalculateChangePct(thisMonthRevenue, lastMonthRevenue),

                ActiveMemberships = activeMemberships,
                VisitsByWeekday = visitsByWeekday,

                BestsellerLast30Days = bestseller == null
                    ? null
                    : new BestSellerDTO
                    {
                        SupplementId = bestseller.SupplementId,
                        Name = bestseller.Name,
                        QuantitySold = bestseller.Quantity
                    }
            };
        }

        private static DateTime GetStartOfWeekUtc(DateTime utcNow)
        {
            // Monday-based week
            var dayOfWeek = (int)utcNow.DayOfWeek; // Sunday=0 ... Saturday=6
            var monday = (int)DayOfWeek.Monday;    // Monday=1
            var offset = (7 + dayOfWeek - monday) % 7;
            return utcNow.Date.AddDays(-offset);
        }

        private static decimal CalculateChangePct(int current, int previous)
        {
            if (previous == 0)
                return current == 0 ? 0m : 100m;

            return Math.Round(((current - previous) / (decimal)previous) * 100m, 2);
        }

        private static decimal CalculateChangePct(decimal current, decimal previous)
        {
            if (previous == 0m)
                return current == 0m ? 0m : 100m;

            return Math.Round(((current - previous) / previous) * 100m, 2);
        }

        private static List<WeekdayVisitsDTO> BuildWeekdayVisits(List<WeekdayVisitsDTO> raw)
        {
            // ensure Monday..Sunday always exists (even if count=0)
            var map = raw.ToDictionary(x => x.Day, x => x.Count);

            var orderedDays = new[]
            {
            DayOfWeek.Monday,
            DayOfWeek.Tuesday,
            DayOfWeek.Wednesday,
            DayOfWeek.Thursday,
            DayOfWeek.Friday,
            DayOfWeek.Saturday,
            DayOfWeek.Sunday
        };

            var result = new List<WeekdayVisitsDTO>(7);

            foreach (var day in orderedDays)
            {
                map.TryGetValue(day, out var count);
                result.Add(new WeekdayVisitsDTO { Day = day, Count = count });
            }

            return result;
        }
    }
}
