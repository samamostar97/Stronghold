using Microsoft.EntityFrameworkCore;
using Stronghold.Application.DTOs.Reports;
using Stronghold.Application.Exceptions;
using Stronghold.Application.Interfaces;
using Stronghold.Core.Enums;
using Stronghold.Infrastructure.Data;
using Stronghold.Infrastructure.Reporting;

namespace Stronghold.Infrastructure.Services;

public class ReportService : IReportService
{
    private const int LowStockThreshold = 10;
    private const int StuckOrderDays = 3;
    private const int AttentionListSize = 5;

    private readonly StrongholdDbContext _db;

    public ReportService(StrongholdDbContext db)
    {
        _db = db;
    }

    public async Task<DashboardResponse> GetDashboardAsync()
    {
        var now = DateTime.UtcNow;
        var today = now.Date;
        var monthStart = new DateTime(now.Year, now.Month, 1);

        var activeMembers = await _db.Memberships
            .Where(m => !m.IsRevoked && m.StartDate <= now && m.EndDate > now)
            .Select(m => m.UserId)
            .Distinct()
            .CountAsync();

        var visitsToday = await _db.GymVisits.CountAsync(v => v.CheckInAt >= today);
        var currentlyInGym = await _db.GymVisits.CountAsync(v => v.CheckOutAt == null);

        var membershipRevenue = await _db.Payments
            .Where(p => p.PaidAt >= monthStart)
            .SumAsync(p => (decimal?)p.Amount) ?? 0;
        var orderRevenue = await _db.Orders
            .Where(o => o.CreatedAt >= monthStart && o.Status != OrderStatus.Cancelled)
            .SumAsync(o => (decimal?)o.TotalAmount) ?? 0;

        var latestOrders = await _db.Orders.AsNoTracking()
            .OrderByDescending(o => o.CreatedAt)
            .Take(5)
            .Select(o => new DashboardOrder
            {
                Id = o.Id,
                UserFullName = o.User.FirstName + " " + o.User.LastName,
                CreatedAt = o.CreatedAt,
                TotalAmount = o.TotalAmount,
                Status = o.Status.ToString(),
                IsNew = o.Status == OrderStatus.Processing && o.StatusChangedAt == null
            })
            .ToListAsync();

        var newOrdersCount = await _db.Orders
            .CountAsync(o => o.Status == OrderStatus.Processing && o.StatusChangedAt == null);

        var lowStockQuery = _db.Supplements
            .Where(s => s.StockQuantity < LowStockThreshold);
        var lowStockCount = await lowStockQuery.CountAsync();
        var lowStock = await lowStockQuery.AsNoTracking()
            .OrderBy(s => s.StockQuantity)
            .ThenBy(s => s.Name)
            .Take(AttentionListSize)
            .Select(s => new LowStockSupplement
            {
                Name = s.Name,
                StockQuantity = s.StockQuantity
            })
            .ToListAsync();

        // clanarina se racuna kao "istice" samo ako clan nema novije clanarine (nije obnovio)
        var weekAhead = now.AddDays(7);
        var expiringQuery = _db.Memberships
            .Where(m => !m.IsRevoked && m.EndDate > now && m.EndDate <= weekAhead &&
                !_db.Memberships.Any(r =>
                    r.UserId == m.UserId && !r.IsRevoked && r.EndDate > m.EndDate));
        var expiringCount = await expiringQuery.CountAsync();
        var expiring = await expiringQuery.AsNoTracking()
            .OrderBy(m => m.EndDate)
            .Take(AttentionListSize)
            .Select(m => new ExpiringMembership
            {
                UserFullName = m.User.FirstName + " " + m.User.LastName,
                PackageName = m.Package.Name,
                EndDate = m.EndDate
            })
            .ToListAsync();

        var stuckBefore = now.AddDays(-StuckOrderDays);
        var stuckQuery = _db.Orders
            .Where(o => o.Status == OrderStatus.Processing && o.CreatedAt < stuckBefore);
        var stuckCount = await stuckQuery.CountAsync();
        var stuckOrders = await stuckQuery.AsNoTracking()
            .OrderBy(o => o.CreatedAt)
            .Take(AttentionListSize)
            .Select(o => new DashboardOrder
            {
                Id = o.Id,
                UserFullName = o.User.FirstName + " " + o.User.LastName,
                CreatedAt = o.CreatedAt,
                TotalAmount = o.TotalAmount,
                Status = o.Status.ToString(),
                IsNew = o.StatusChangedAt == null
            })
            .ToListAsync();

        return new DashboardResponse
        {
            ActiveMembers = activeMembers,
            VisitsToday = visitsToday,
            CurrentlyInGym = currentlyInGym,
            RevenueThisMonth = membershipRevenue + orderRevenue,
            NewOrdersCount = newOrdersCount,
            LatestOrders = latestOrders,
            LowStockSupplements = lowStock,
            LowStockCount = lowStockCount,
            ExpiringMemberships = expiring,
            ExpiringMembershipsCount = expiringCount,
            StuckOrders = stuckOrders,
            StuckOrdersCount = stuckCount
        };
    }

    public async Task<RevenueReportResponse> GetRevenueReportAsync()
    {
        var now = DateTime.UtcNow;
        var from = new DateTime(now.Year, now.Month, 1).AddMonths(-5);

        // agregacije jednim GroupBy upitom po izvoru prihoda
        var membershipByMonth = await _db.Payments
            .Where(p => p.PaidAt >= from)
            .GroupBy(p => new { p.PaidAt.Year, p.PaidAt.Month })
            .Select(g => new { g.Key.Year, g.Key.Month, Total = g.Sum(p => p.Amount) })
            .ToListAsync();

        var ordersByMonth = await _db.Orders
            .Where(o => o.CreatedAt >= from && o.Status != OrderStatus.Cancelled)
            .GroupBy(o => new { o.CreatedAt.Year, o.CreatedAt.Month })
            .Select(g => new { g.Key.Year, g.Key.Month, Total = g.Sum(o => o.TotalAmount) })
            .ToListAsync();

        var monthly = new List<MonthlyRevenue>();
        for (var month = from; month <= now; month = month.AddMonths(1))
        {
            monthly.Add(new MonthlyRevenue
            {
                Year = month.Year,
                Month = month.Month,
                MembershipRevenue = membershipByMonth
                    .FirstOrDefault(m => m.Year == month.Year && m.Month == month.Month)?.Total ?? 0,
                OrderRevenue = ordersByMonth
                    .FirstOrDefault(o => o.Year == month.Year && o.Month == month.Month)?.Total ?? 0
            });
        }

        var topProducts = await _db.OrderItems
            .Where(i => i.Order.Status != OrderStatus.Cancelled)
            .GroupBy(i => i.Supplement.Name)
            .Select(g => new TopProduct
            {
                Name = g.Key,
                QuantitySold = g.Sum(i => i.Quantity),
                Revenue = g.Sum(i => i.Quantity * i.UnitPrice)
            })
            .OrderByDescending(p => p.QuantitySold)
            .Take(5)
            .ToListAsync();

        return new RevenueReportResponse
        {
            MonthlyRevenue = monthly,
            TopProducts = topProducts,
            TotalMembershipRevenue = await _db.Payments.SumAsync(p => (decimal?)p.Amount) ?? 0,
            TotalOrderRevenue = await _db.Orders
                .Where(o => o.Status != OrderStatus.Cancelled)
                .SumAsync(o => (decimal?)o.TotalAmount) ?? 0
        };
    }

    public async Task<InventoryReportResponse> GetInventoryReportAsync()
    {
        var items = await _db.Supplements.AsNoTracking()
            .OrderBy(s => s.StockQuantity)
            .Select(s => new InventoryItem
            {
                Name = s.Name,
                CategoryName = s.Category.Name,
                SupplierName = s.Supplier.Name,
                StockQuantity = s.StockQuantity,
                Price = s.Price,
                StockValue = s.StockQuantity * s.Price
            })
            .ToListAsync();

        return new InventoryReportResponse
        {
            Items = items,
            TotalValue = items.Sum(i => i.StockValue),
            LowStockCount = items.Count(i => i.StockQuantity < LowStockThreshold)
        };
    }

    public async Task<MembershipReportResponse> GetMembershipReportAsync()
    {
        var now = DateTime.UtcNow;

        var activeCount = await _db.Memberships
            .Where(m => !m.IsRevoked && m.StartDate <= now && m.EndDate > now)
            .Select(m => m.UserId)
            .Distinct()
            .CountAsync();

        var expiringSoon = await _db.Memberships
            .CountAsync(m => !m.IsRevoked && m.EndDate > now && m.EndDate <= now.AddDays(7));

        var byPackage = await _db.Memberships
            .Where(m => !m.IsRevoked && m.StartDate <= now && m.EndDate > now)
            .GroupBy(m => m.Package.Name)
            .Select(g => new PackageDistribution
            {
                PackageName = g.Key,
                ActiveCount = g.Count()
            })
            .OrderByDescending(p => p.ActiveCount)
            .ToListAsync();

        // posjecenost po sedmicama za zadnjih 8 sedmica
        var eightWeeksAgo = now.Date.AddDays(-7 * 8);
        var visits = await _db.GymVisits
            .Where(v => v.CheckInAt >= eightWeeksAgo)
            .Select(v => v.CheckInAt)
            .ToListAsync();

        var weekly = new List<WeeklyVisitCount>();
        for (var week = 0; week < 8; week++)
        {
            var start = eightWeeksAgo.AddDays(week * 7);
            var end = start.AddDays(7);
            weekly.Add(new WeeklyVisitCount
            {
                WeekStart = start,
                Count = visits.Count(v => v >= start && v < end)
            });
        }

        return new MembershipReportResponse
        {
            ActiveCount = activeCount,
            ExpiringIn7Days = expiringSoon,
            ByPackage = byPackage,
            WeeklyVisits = weekly
        };
    }

    public async Task<byte[]> ExportPdfAsync(string reportKey)
    {
        return reportKey switch
        {
            "revenue" => ReportPdfBuilder.BuildRevenue(await GetRevenueReportAsync()),
            "inventory" => ReportPdfBuilder.BuildInventory(await GetInventoryReportAsync()),
            "memberships" => ReportPdfBuilder.BuildMemberships(await GetMembershipReportAsync()),
            _ => throw new NotFoundException("Nepoznat izvještaj. Dostupni: revenue, inventory, memberships.")
        };
    }

    public async Task<byte[]> ExportExcelAsync(string reportKey)
    {
        return reportKey switch
        {
            "revenue" => ReportExcelBuilder.BuildRevenue(await GetRevenueReportAsync()),
            "inventory" => ReportExcelBuilder.BuildInventory(await GetInventoryReportAsync()),
            "memberships" => ReportExcelBuilder.BuildMemberships(await GetMembershipReportAsync()),
            _ => throw new NotFoundException("Nepoznat izvještaj. Dostupni: revenue, inventory, memberships.")
        };
    }
}
