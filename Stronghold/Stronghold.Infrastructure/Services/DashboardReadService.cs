using Microsoft.EntityFrameworkCore;
using Stronghold.Application.Features.Dashboard.DTOs;
using Stronghold.Application.Features.Reports.DTOs;
using Stronghold.Application.IServices;
using Stronghold.Core.Enums;
using Stronghold.Infrastructure.Data;

namespace Stronghold.Infrastructure.Services
{
    public class DashboardReadService : IDashboardReadService
    {
        private readonly StrongholdDbContext _context;

        public DashboardReadService(StrongholdDbContext context)
        {
            _context = context;
        }

        public async Task<DashboardOverviewResponse> GetOverviewAsync(int days = 30)
        {
            var now = DateTime.UtcNow;
            var since = now.AddDays(-days);
            var todayStart = now.Date;
            var todayEnd = todayStart.AddDays(1);
            var oneWeekFromNow = now.AddDays(7);

            var activeMemberships = await _context.Memberships
                .AsNoTracking()
                .Where(m => !m.IsDeleted && m.StartDate <= now && m.EndDate >= now)
                .CountAsync();

            var expiringThisWeekCount = await _context.Memberships
                .AsNoTracking()
                .Where(m => !m.IsDeleted && m.StartDate <= now && m.EndDate >= now && m.EndDate < oneWeekFromNow)
                .CountAsync();

            var todayCheckIns = await _context.GymVisits
                .AsNoTracking()
                .Where(v => !v.IsDeleted && v.CheckInTime >= todayStart && v.CheckInTime < todayEnd)
                .CountAsync();

            var dailyVisitData = await _context.GymVisits
                .AsNoTracking()
                .Where(v => !v.IsDeleted && v.CheckInTime >= since && v.CheckInTime < todayEnd)
                .GroupBy(v => v.CheckInTime.Date)
                .Select(g => new { Date = g.Key, Count = g.Count() })
                .ToListAsync();

            var dailyVisits = new List<DailyVisitsResponse>();
            for (var d = since.Date; d <= now.Date; d = d.AddDays(1))
            {
                var entry = dailyVisitData.FirstOrDefault(x => x.Date == d);
                dailyVisits.Add(new DailyVisitsResponse
                {
                    Date = d,
                    VisitCount = entry?.Count ?? 0
                });
            }

            return new DashboardOverviewResponse
            {
                ActiveMemberships = activeMemberships,
                ExpiringThisWeekCount = expiringThisWeekCount,
                TodayCheckIns = todayCheckIns,
                DailyVisits = dailyVisits,
            };
        }

        public async Task<DashboardSalesResponse> GetSalesAsync()
        {
            var now = DateTime.UtcNow;
            var since = now.AddDays(-30);

            var dailyOrderData = await _context.Orders
                .AsNoTracking()
                .Where(o => !o.IsDeleted && o.PurchaseDate >= since && o.PurchaseDate <= now)
                .GroupBy(o => o.PurchaseDate.Date)
                .Select(g => new
                {
                    Date = g.Key,
                    Revenue = g.Sum(x => x.TotalAmount),
                    OrderCount = g.Count()
                })
                .ToListAsync();

            var dailySales = new List<DailySalesResponse>();
            for (var d = since.Date; d <= now.Date; d = d.AddDays(1))
            {
                var entry = dailyOrderData.FirstOrDefault(x => x.Date == d);
                dailySales.Add(new DailySalesResponse
                {
                    Date = d,
                    Revenue = entry?.Revenue ?? 0m,
                    OrderCount = entry?.OrderCount ?? 0
                });
            }

            return new DashboardSalesResponse
            {
                DailySales = dailySales,
                TotalRevenue = dailyOrderData.Sum(d => d.Revenue),
                TotalOrders = dailyOrderData.Sum(d => d.OrderCount),
            };
        }

        public async Task<DashboardAttentionResponse> GetAttentionAsync(int days = 7)
        {
            var now = DateTime.UtcNow;
            var cutoff = now.AddDays(days);

            var pendingOrdersCount = await _context.Orders
                .AsNoTracking()
                .Where(o => !o.IsDeleted && o.Status == OrderStatus.Processing)
                .CountAsync();

            var expiringMembershipsCount = await _context.Memberships
                .AsNoTracking()
                .Where(m => !m.IsDeleted && m.StartDate <= now && m.EndDate > now && m.EndDate <= cutoff)
                .CountAsync();

            return new DashboardAttentionResponse
            {
                PendingOrdersCount = pendingOrdersCount,
                ExpiringMembershipsCount = expiringMembershipsCount,
                WindowDays = days,
            };
        }

        public async Task<List<ActivityFeedItemResponse>> GetActivityFeedAsync(int count = 20)
        {
            var feed = new List<ActivityFeedItemResponse>();

            var recentOrders = await _context.Orders
                .AsNoTracking()
                .Where(o => !o.IsDeleted && !o.User.IsDeleted)
                .OrderByDescending(o => o.PurchaseDate)
                .Take(count)
                .Select(o => new ActivityFeedItemResponse
                {
                    Type = "order",
                    Description = $"Nova narudzba - {o.TotalAmount:F2} KM",
                    Timestamp = o.PurchaseDate,
                    UserName = o.User.FirstName + " " + o.User.LastName
                })
                .ToListAsync();

            feed.AddRange(recentOrders);

            var recentRegistrations = await _context.Users
                .AsNoTracking()
                .Where(u => !u.IsDeleted)
                .OrderByDescending(u => u.CreatedAt)
                .Take(count)
                .Select(u => new ActivityFeedItemResponse
                {
                    Type = "registration",
                    Description = "Novi korisnik registrovan",
                    Timestamp = u.CreatedAt,
                    UserName = u.FirstName + " " + u.LastName
                })
                .ToListAsync();

            feed.AddRange(recentRegistrations);

            var recentMemberships = await _context.Memberships
                .AsNoTracking()
                .Where(m => !m.IsDeleted && !m.User.IsDeleted && !m.MembershipPackage.IsDeleted)
                .OrderByDescending(m => m.CreatedAt)
                .Take(count)
                .Select(m => new ActivityFeedItemResponse
                {
                    Type = "membership",
                    Description = $"Nova clanarina - {m.MembershipPackage.PackageName}",
                    Timestamp = m.CreatedAt,
                    UserName = m.User.FirstName + " " + m.User.LastName
                })
                .ToListAsync();

            feed.AddRange(recentMemberships);

            return feed
                .OrderByDescending(f => f.Timestamp)
                .Take(count)
                .ToList();
        }
    }
}
