using System.Globalization;
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
    private const int MaxPeriodMonths = 24;

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

    public async Task<RevenueReportResponse> GetRevenueReportAsync(string? from, string? to)
    {
        var (fromDate, toExclusive) = ResolvePeriod(from, to);

        // agregacije jednim GroupBy upitom po izvoru prihoda
        var membershipByMonth = await _db.Payments
            .Where(p => p.PaidAt >= fromDate && p.PaidAt < toExclusive)
            .GroupBy(p => new { p.PaidAt.Year, p.PaidAt.Month })
            .Select(g => new { g.Key.Year, g.Key.Month, Total = g.Sum(p => p.Amount) })
            .ToListAsync();

        var ordersByMonth = await _db.Orders
            .Where(o => o.CreatedAt >= fromDate && o.CreatedAt < toExclusive &&
                        o.Status != OrderStatus.Cancelled)
            .GroupBy(o => new { o.CreatedAt.Year, o.CreatedAt.Month })
            .Select(g => new { g.Key.Year, g.Key.Month, Total = g.Sum(o => o.TotalAmount) })
            .ToListAsync();

        var monthly = new List<MonthlyRevenue>();
        for (var month = fromDate; month < toExclusive; month = month.AddMonths(1))
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
            .Where(i => i.Order.Status != OrderStatus.Cancelled &&
                        i.Order.CreatedAt >= fromDate && i.Order.CreatedAt < toExclusive)
            .GroupBy(i => new { i.Supplement.Name, CategoryName = i.Supplement.Category.Name })
            .Select(g => new TopProduct
            {
                Name = g.Key.Name,
                CategoryName = g.Key.CategoryName,
                QuantitySold = g.Sum(i => i.Quantity),
                Revenue = g.Sum(i => i.Quantity * i.UnitPrice)
            })
            .OrderByDescending(p => p.QuantitySold)
            .Take(10)
            .ToListAsync();

        var packageSales = await _db.Payments
            .Where(p => p.PaidAt >= fromDate && p.PaidAt < toExclusive)
            .GroupBy(p => p.Membership.Package.Name)
            .Select(g => new PackageSales
            {
                PackageName = g.Key,
                SoldCount = g.Count(),
                Revenue = g.Sum(p => p.Amount)
            })
            .OrderByDescending(p => p.Revenue)
            .ToListAsync();

        // novi clan = korisnik cija PRVA clanarina pocinje u periodu
        var newMembers = await _db.Memberships
            .GroupBy(m => m.UserId)
            .CountAsync(g => g.Min(m => m.StartDate) >= fromDate &&
                             g.Min(m => m.StartDate) < toExclusive);

        var visitCount = await _db.GymVisits
            .CountAsync(v => v.CheckInAt >= fromDate && v.CheckInAt < toExclusive);

        var membershipRevenue = monthly.Sum(m => m.MembershipRevenue);
        var orderRevenue = monthly.Sum(m => m.OrderRevenue);
        var toDate = toExclusive.AddMonths(-1);

        return new RevenueReportResponse
        {
            FromYear = fromDate.Year,
            FromMonth = fromDate.Month,
            ToYear = toDate.Year,
            ToMonth = toDate.Month,
            TotalRevenue = membershipRevenue + orderRevenue,
            MembershipRevenue = membershipRevenue,
            OrderRevenue = orderRevenue,
            NewMembers = newMembers,
            VisitCount = visitCount,
            MonthlyRevenue = monthly,
            TopProducts = topProducts,
            PackageSales = packageSales
        };
    }

    public async Task<StaffReportResponse> GetStaffReportAsync(string? from, string? to)
    {
        var (fromDate, toExclusive) = ResolvePeriod(from, to);
        var fromDay = DateOnly.FromDateTime(fromDate);
        var toDayExclusive = DateOnly.FromDateTime(toExclusive);

        var inPeriod = _db.Appointments
            .Where(a => a.Date >= fromDay && a.Date < toDayExclusive);

        var staff = await inPeriod
            .GroupBy(a => new
            {
                a.StaffMemberId,
                a.StaffMember.FirstName,
                a.StaffMember.LastName,
                a.StaffMember.StaffType
            })
            .Select(g => new StaffAppointmentStat
            {
                FullName = g.Key.FirstName + " " + g.Key.LastName,
                StaffType = g.Key.StaffType.ToString(),
                TotalCount = g.Count(),
                CompletedCount = g.Count(a => a.Status == AppointmentStatus.Completed),
                CancelledCount = g.Count(a => a.Status == AppointmentStatus.Cancelled),
                UpcomingCount = g.Count(a =>
                    a.Status == AppointmentStatus.Pending || a.Status == AppointmentStatus.Confirmed)
            })
            .ToListAsync();
        staff = staff.OrderByDescending(s => s.TotalCount).ThenBy(s => s.FullName).ToList();

        var busiestHour = await inPeriod
            .GroupBy(a => a.StartHour)
            .Select(g => new { Hour = g.Key, Count = g.Count() })
            .OrderByDescending(x => x.Count)
            .FirstOrDefaultAsync();

        var busiestStaff = staff.FirstOrDefault();
        var toDate = toExclusive.AddMonths(-1);

        return new StaffReportResponse
        {
            FromYear = fromDate.Year,
            FromMonth = fromDate.Month,
            ToYear = toDate.Year,
            ToMonth = toDate.Month,
            TotalAppointments = staff.Sum(s => s.TotalCount),
            CompletedCount = staff.Sum(s => s.CompletedCount),
            CancelledCount = staff.Sum(s => s.CancelledCount),
            UpcomingCount = staff.Sum(s => s.UpcomingCount),
            BusiestStaffName = busiestStaff?.FullName,
            BusiestStaffCount = busiestStaff?.TotalCount ?? 0,
            BusiestHour = busiestHour?.Hour,
            BusiestHourCount = busiestHour?.Count ?? 0,
            Staff = staff
        };
    }

    public async Task<byte[]> ExportPdfAsync(string reportKey, string? from, string? to)
    {
        return reportKey switch
        {
            "revenue" => ReportPdfBuilder.BuildRevenue(await GetRevenueReportAsync(from, to)),
            "staff" => ReportPdfBuilder.BuildStaff(await GetStaffReportAsync(from, to)),
            _ => throw new NotFoundException("Nepoznat izvještaj. Dostupni: revenue, staff.")
        };
    }

    public async Task<byte[]> ExportExcelAsync(string reportKey, string? from, string? to)
    {
        return reportKey switch
        {
            "revenue" => ReportExcelBuilder.BuildRevenue(await GetRevenueReportAsync(from, to)),
            "staff" => ReportExcelBuilder.BuildStaff(await GetStaffReportAsync(from, to)),
            _ => throw new NotFoundException("Nepoznat izvještaj. Dostupni: revenue, staff.")
        };
    }

    /// <summary>Granice perioda iz "GGGG-MM" parametara; default je zadnjih 6 mjeseci.</summary>
    private static (DateTime FromDate, DateTime ToExclusive) ResolvePeriod(string? from, string? to)
    {
        var now = DateTime.UtcNow;
        var currentMonth = new DateTime(now.Year, now.Month, 1);

        var fromDate = ParseMonth(from) ?? currentMonth.AddMonths(-5);
        var toDate = ParseMonth(to) ?? currentMonth;

        if (fromDate > toDate)
        {
            throw new BusinessException("Početni mjesec perioda ne može biti poslije krajnjeg.");
        }
        var months = (toDate.Year - fromDate.Year) * 12 + toDate.Month - fromDate.Month + 1;
        if (months > MaxPeriodMonths)
        {
            throw new BusinessException($"Period može obuhvatiti najviše {MaxPeriodMonths} mjeseca.");
        }
        return (fromDate, toDate.AddMonths(1));
    }

    private static DateTime? ParseMonth(string? value)
    {
        if (string.IsNullOrWhiteSpace(value))
        {
            return null;
        }
        if (!DateTime.TryParseExact(value, "yyyy-MM", CultureInfo.InvariantCulture,
                DateTimeStyles.None, out var parsed))
        {
            throw new BusinessException("Neispravan period. Očekivani format: GGGG-MM (npr. 2026-03).");
        }
        return parsed;
    }
}
