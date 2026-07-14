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
    private const int MaxPeriodDays = 366;

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

    public async Task<MembershipsReportResponse> GetMembershipsReportAsync(
        string? from, string? to, int? userId)
    {
        var (fromDate, toExclusive) = ResolvePeriod(from, to);
        var userFullName = await ResolveUserNameAsync(userId);

        var payments = await _db.Payments.AsNoTracking()
            .Where(p => p.PaidAt >= fromDate && p.PaidAt < toExclusive)
            .Where(p => userId == null || p.Membership.UserId == userId)
            .OrderByDescending(p => p.PaidAt)
            .Select(p => new PaymentRow
            {
                PaidAt = p.PaidAt,
                UserFullName = p.Membership.User.FirstName + " " + p.Membership.User.LastName,
                PackageName = p.Membership.Package.Name,
                Amount = p.Amount
            })
            .ToListAsync();

        return new MembershipsReportResponse
        {
            FromDate = fromDate,
            ToDate = toExclusive.AddDays(-1),
            UserFullName = userFullName,
            TotalAmount = payments.Sum(p => p.Amount),
            PaymentCount = payments.Count,
            Payments = payments
        };
    }

    public async Task<ShopReportResponse> GetShopReportAsync(string? from, string? to, int? userId)
    {
        var (fromDate, toExclusive) = ResolvePeriod(from, to);
        var userFullName = await ResolveUserNameAsync(userId);

        var rows = await _db.Orders.AsNoTracking()
            .Where(o => o.CreatedAt >= fromDate && o.CreatedAt < toExclusive &&
                        o.Status != OrderStatus.Cancelled)
            .Where(o => userId == null || o.UserId == userId)
            .OrderByDescending(o => o.CreatedAt)
            .Select(o => new
            {
                o.CreatedAt,
                UserFullName = o.User.FirstName + " " + o.User.LastName,
                ItemCount = o.Items.Sum(i => i.Quantity),
                o.TotalAmount,
                o.Status
            })
            .ToListAsync();

        var orders = rows.Select(r => new OrderRow
        {
            CreatedAt = r.CreatedAt,
            UserFullName = r.UserFullName,
            ItemCount = r.ItemCount,
            TotalAmount = r.TotalAmount,
            Status = OrderStatusLabel(r.Status)
        }).ToList();

        return new ShopReportResponse
        {
            FromDate = fromDate,
            ToDate = toExclusive.AddDays(-1),
            UserFullName = userFullName,
            TotalRevenue = orders.Sum(o => o.TotalAmount),
            OrderCount = orders.Count,
            Orders = orders
        };
    }

    public async Task<byte[]> ExportPdfAsync(string reportKey, string? from, string? to, int? userId)
    {
        return reportKey switch
        {
            "memberships" => ReportPdfBuilder.BuildMemberships(
                await GetMembershipsReportAsync(from, to, userId)),
            "shop" => ReportPdfBuilder.BuildShop(await GetShopReportAsync(from, to, userId)),
            _ => throw new NotFoundException("Nepoznat izvještaj. Dostupni: memberships, shop.")
        };
    }

    public async Task<byte[]> ExportExcelAsync(string reportKey, string? from, string? to, int? userId)
    {
        return reportKey switch
        {
            "memberships" => ReportExcelBuilder.BuildMemberships(
                await GetMembershipsReportAsync(from, to, userId)),
            "shop" => ReportExcelBuilder.BuildShop(await GetShopReportAsync(from, to, userId)),
            _ => throw new NotFoundException("Nepoznat izvještaj. Dostupni: memberships, shop.")
        };
    }

    /// <summary>Granice perioda iz "GGGG-MM-DD" parametara; default je zadnjih 30 dana.
    /// Datumi se porede s UTC vremenima zapisa (konvencija cijele aplikacije).</summary>
    private static (DateTime FromDate, DateTime ToExclusive) ResolvePeriod(string? from, string? to)
    {
        var today = DateTime.UtcNow.Date;

        var fromDate = ParseDay(from) ?? today.AddDays(-29);
        var toDate = ParseDay(to) ?? today;

        if (fromDate > toDate)
        {
            throw new BusinessException("Početni datum perioda ne može biti poslije krajnjeg.");
        }
        if ((toDate - fromDate).Days + 1 > MaxPeriodDays)
        {
            throw new BusinessException($"Period može obuhvatiti najviše {MaxPeriodDays} dana.");
        }
        return (fromDate, toDate.AddDays(1));
    }

    private static DateTime? ParseDay(string? value)
    {
        if (string.IsNullOrWhiteSpace(value))
        {
            return null;
        }
        if (!DateTime.TryParseExact(value, "yyyy-MM-dd", CultureInfo.InvariantCulture,
                DateTimeStyles.None, out var parsed))
        {
            throw new BusinessException(
                "Neispravan datum. Očekivani format: GGGG-MM-DD (npr. 2026-03-15).");
        }
        return parsed.Date;
    }

    private async Task<string?> ResolveUserNameAsync(int? userId)
    {
        if (userId == null)
        {
            return null;
        }
        var name = await _db.Users
            .Where(u => u.Id == userId)
            .Select(u => u.FirstName + " " + u.LastName)
            .FirstOrDefaultAsync();
        return name ?? throw new NotFoundException("Član nije pronađen.");
    }

    private static string OrderStatusLabel(OrderStatus status) => status switch
    {
        OrderStatus.Processing => "U obradi",
        OrderStatus.Shipped => "Poslano",
        OrderStatus.Delivered => "Dostavljeno",
        _ => status.ToString()
    };
}
