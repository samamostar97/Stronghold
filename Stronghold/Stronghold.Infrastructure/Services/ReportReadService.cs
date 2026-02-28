using Microsoft.EntityFrameworkCore;
using Stronghold.Application.Common;
using Stronghold.Application.Features.Reports.DTOs;
using Stronghold.Application.IServices;
using Stronghold.Core.Enums;
using Stronghold.Infrastructure.Data;

namespace Stronghold.Infrastructure.Services
{
    public class ReportReadService : IReportReadService
    {
        private readonly StrongholdDbContext _context;

        public ReportReadService(StrongholdDbContext context)
        {
            _context = context;
        }

        public async Task<BusinessReportResponse> GetBusinessReportAsync(int days = 30)
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

            var todayStart = now.Date;
            var todayEnd = todayStart.AddDays(1);
            var thirtyDaysAgo = now.AddDays(-30);

            // Ensure `since` covers lastMonth too (for lastMonthOrderRevenue derivation)
            var since = new[] { now.AddDays(-days), startOfLastMonth }.Min();

            // ── Bulk query: daily order data (covers since..now) ──
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

            // Derive order revenue/counts from dailyOrderData in-memory
            var todayOrderRevenue = dailyOrderData.Where(d => d.Date >= todayStart && d.Date < todayEnd).Sum(d => d.Revenue);
            var todayOrderCount = dailyOrderData.Where(d => d.Date >= todayStart && d.Date < todayEnd).Sum(d => d.OrderCount);
            var weekOrderRevenue = dailyOrderData.Where(d => d.Date >= startOfWeek && d.Date < startOfNextWeek).Sum(d => d.Revenue);
            var monthOrderRevenue = dailyOrderData.Where(d => d.Date >= startOfMonth && d.Date < startOfNextMonth).Sum(d => d.Revenue);
            var monthOrderCount = dailyOrderData.Where(d => d.Date >= startOfMonth && d.Date < startOfNextMonth).Sum(d => d.OrderCount);
            var lastMonthOrderRevenue = dailyOrderData.Where(d => d.Date >= startOfLastMonth && d.Date < startOfMonth).Sum(d => d.Revenue);

            var avgOrderValue = monthOrderCount > 0 ? Math.Round(monthOrderRevenue / monthOrderCount, 2) : 0m;

            // Build daily sales list for the chart (uses the user-requested period)
            var chartSince = now.AddDays(-days);
            var dailySales = new List<DailySalesResponse>();
            for (var d = chartSince.Date; d <= now.Date; d = d.AddDays(1))
            {
                var entry = dailyOrderData.FirstOrDefault(x => x.Date == d);
                dailySales.Add(new DailySalesResponse
                {
                    Date = d,
                    Revenue = entry?.Revenue ?? 0m,
                    OrderCount = entry?.OrderCount ?? 0
                });
            }

            // ── Bulk query: daily membership payment data (covers lastMonth..now) ──
            var dailyMembershipData = await _context.MembershipPaymentHistory
                .AsNoTracking()
                .Where(p => !p.IsDeleted && p.PaymentDate >= startOfLastMonth && p.PaymentDate < startOfNextMonth)
                .GroupBy(p => p.PaymentDate.Date)
                .Select(g => new
                {
                    Date = g.Key,
                    Revenue = g.Sum(x => x.AmountPaid)
                })
                .ToListAsync();

            var todayMembershipRevenue = dailyMembershipData.Where(d => d.Date >= todayStart && d.Date < todayEnd).Sum(d => d.Revenue);
            var weekMembershipRevenue = dailyMembershipData.Where(d => d.Date >= startOfWeek && d.Date < startOfNextWeek).Sum(d => d.Revenue);
            var thisMonthMembershipRevenue = dailyMembershipData.Where(d => d.Date >= startOfMonth && d.Date < startOfNextMonth).Sum(d => d.Revenue);
            var lastMonthMembershipRevenue = dailyMembershipData.Where(d => d.Date >= startOfLastMonth && d.Date < startOfMonth).Sum(d => d.Revenue);

            // ── Bulk query: daily visit data (covers lastWeek..today) ──
            var visitDataSince = new[] { thirtyDaysAgo, lastWeekStart }.Min();
            var dailyVisitData = await _context.GymVisits
                .AsNoTracking()
                .Where(v => !v.IsDeleted && v.CheckInTime >= visitDataSince && v.CheckInTime < todayEnd)
                .GroupBy(v => v.CheckInTime.Date)
                .Select(g => new { Date = g.Key, Count = g.Count() })
                .ToListAsync();

            // Derive visit counts from dailyVisitData in-memory
            var todayCheckIns = dailyVisitData.Where(d => d.Date >= todayStart && d.Date < todayEnd).Sum(d => d.Count);
            var thisWeekVisits = dailyVisitData.Where(d => d.Date >= startOfWeek && d.Date < startOfNextWeek).Sum(d => d.Count);
            var lastWeekVisits = dailyVisitData.Where(d => d.Date >= lastWeekStart && d.Date < startOfWeek).Sum(d => d.Count);
            var last30DaysCheckIns = dailyVisitData.Where(d => d.Date >= thirtyDaysAgo && d.Date < todayEnd).Sum(d => d.Count);
            var thisMonthVisits = dailyVisitData.Where(d => d.Date >= startOfMonth && d.Date < startOfNextMonth).Sum(d => d.Count);
            var avgDailyCheckIns = Math.Round(last30DaysCheckIns / 30m, 1);

            // Growth rate from dailyVisitData (split 30 days in half)
            var halfPoint = thirtyDaysAgo.AddDays(15);
            var firstHalfVisits = dailyVisitData.Where(d => d.Date >= thirtyDaysAgo && d.Date < halfPoint).Sum(d => d.Count);
            var secondHalfVisits = dailyVisitData.Where(d => d.Date >= halfPoint && d.Date < todayEnd).Sum(d => d.Count);
            var growthPct = firstHalfVisits > 0
                ? Math.Round((secondHalfVisits - firstHalfVisits) / (decimal)firstHalfVisits * 100, 1)
                : secondHalfVisits > 0 ? 100m : 0m;

            // Build daily visits list for the chart
            var dailyVisits = new List<DailyVisitsResponse>();
            for (var d = thirtyDaysAgo.Date; d <= now.Date; d = d.AddDays(1))
            {
                var entry = dailyVisitData.FirstOrDefault(x => x.Date == d);
                dailyVisits.Add(new DailyVisitsResponse
                {
                    Date = d,
                    VisitCount = entry?.Count ?? 0
                });
            }

            // ── SQL-side visits by weekday (current week) ──
            var rawByDay = await _context.GymVisits
                .AsNoTracking()
                .Where(v => !v.IsDeleted && v.CheckInTime >= startOfWeek && v.CheckInTime < startOfNextWeek)
                .GroupBy(v => v.CheckInTime.DayOfWeek)
                .Select(g => new WeekdayVisitsResponse
                {
                    Day = g.Key,
                    Count = g.Count()
                })
                .ToListAsync();

            var visitsByWeekday = BuildWeekdayVisits(rawByDay);

            // ── SQL-side heatmap (day × hour, current week) ──
            var heatmapRows = await _context.GymVisits
                .AsNoTracking()
                .Where(v => !v.IsDeleted && v.CheckInTime >= startOfWeek && v.CheckInTime < startOfNextWeek)
                .GroupBy(v => new { v.CheckInTime.DayOfWeek, v.CheckInTime.Hour })
                .Select(g => new HeatmapCellResponse
                {
                    Day = g.Key.DayOfWeek,
                    Hour = g.Key.Hour,
                    Count = g.Count()
                })
                .ToListAsync();

            var heatmapDict = heatmapRows.ToDictionary(c => (c.Day, c.Hour), c => c.Count);

            var orderedDaysForHeatmap = new[]
            {
                DayOfWeek.Monday, DayOfWeek.Tuesday, DayOfWeek.Wednesday,
                DayOfWeek.Thursday, DayOfWeek.Friday, DayOfWeek.Saturday, DayOfWeek.Sunday
            };

            var checkInHeatmap = new List<HeatmapCellResponse>();
            foreach (var day in orderedDaysForHeatmap)
            {
                for (var hour = 0; hour < 24; hour++)
                {
                    heatmapDict.TryGetValue((day, hour), out var count);
                    checkInHeatmap.Add(new HeatmapCellResponse { Day = day, Hour = hour, Count = count });
                }
            }

            // ── Bestseller (configurable period) ──
            var bestseller = await _context.OrderItems
                .AsNoTracking()
                .Where(oi => !oi.IsDeleted &&
                             !oi.Order.IsDeleted &&
                             oi.Order.PurchaseDate >= chartSince &&
                             oi.Order.PurchaseDate <= now)
                .GroupBy(oi => new { oi.SupplementId, oi.Supplement.Name })
                .Select(g => new
                {
                    g.Key.SupplementId,
                    g.Key.Name,
                    Quantity = g.Sum(x => x.Quantity)
                })
                .OrderByDescending(x => x.Quantity)
                .FirstOrDefaultAsync();

            // Slowest-moving supplement (fewest sales in period, at least 1 sale)
            var worstSeller = await _context.OrderItems
                .AsNoTracking()
                .Where(oi => !oi.IsDeleted &&
                             !oi.Order.IsDeleted &&
                             oi.Order.PurchaseDate >= chartSince &&
                             oi.Order.PurchaseDate <= now)
                .GroupBy(oi => new { oi.SupplementId, oi.Supplement.Name })
                .Select(g => new
                {
                    g.Key.SupplementId,
                    g.Key.Name,
                    Quantity = g.Sum(x => x.Quantity),
                    LastSaleDate = g.Max(x => x.Order.PurchaseDate)
                })
                .OrderBy(x => x.Quantity)
                .FirstOrDefaultAsync();

            // Active memberships
            var activeMemberships = await _context.Memberships
                .AsNoTracking()
                .Where(m => !m.IsDeleted && m.StartDate <= now && m.EndDate >= now)
                .CountAsync();

            // Memberships expiring this week
            var oneWeekFromNow = now.AddDays(7);
            var expiringThisWeekCount = await _context.Memberships
                .AsNoTracking()
                .Where(m => !m.IsDeleted && m.StartDate <= now && m.EndDate >= now && m.EndDate < oneWeekFromNow)
                .CountAsync();

            var revenueBreakdown = new RevenueBreakdownResponse
            {
                TodayRevenue = todayOrderRevenue + todayMembershipRevenue,
                ThisWeekRevenue = weekOrderRevenue + weekMembershipRevenue,
                ThisMonthRevenue = monthOrderRevenue + thisMonthMembershipRevenue,
                AverageOrderValue = avgOrderValue,
                TodayOrderCount = todayOrderCount,
                MonthOrderRevenue = monthOrderRevenue
            };

            // Popular membership (most purchased in period)
            var popularMembership = await _context.Memberships
                .AsNoTracking()
                .Where(m => !m.IsDeleted && m.StartDate >= chartSince && m.StartDate <= now)
                .GroupBy(m => new { m.MembershipPackageId, m.MembershipPackage.PackageName })
                .Select(g => new
                {
                    g.Key.MembershipPackageId,
                    PackageName = g.Key.PackageName,
                    PurchaseCount = g.Count()
                })
                .OrderByDescending(x => x.PurchaseCount)
                .FirstOrDefaultAsync();

            // Busiest day this month
            var busiestDayData = await _context.GymVisits
                .AsNoTracking()
                .Where(v => !v.IsDeleted && v.CheckInTime >= startOfMonth && v.CheckInTime < startOfNextMonth)
                .GroupBy(v => v.CheckInTime.Date)
                .Select(g => new { Date = g.Key, Count = g.Count() })
                .OrderByDescending(x => x.Count)
                .FirstOrDefaultAsync();

            // Most active membership package by visits (this month) — proper join
            var mostActivePackage = await _context.GymVisits
                .AsNoTracking()
                .Where(v => !v.IsDeleted && v.CheckInTime >= startOfMonth && v.CheckInTime < startOfNextMonth)
                .Join(
                    _context.Memberships.AsNoTracking().Where(m => !m.IsDeleted),
                    v => v.UserId,
                    m => m.UserId,
                    (v, m) => new { Visit = v, Membership = m })
                .Where(x => x.Membership.StartDate <= x.Visit.CheckInTime && x.Membership.EndDate >= x.Visit.CheckInTime)
                .GroupBy(x => x.Membership.MembershipPackage.PackageName)
                .Select(g => new { PackageName = g.Key, VisitCount = g.Count() })
                .OrderByDescending(x => x.VisitCount)
                .FirstOrDefaultAsync();

            return new BusinessReportResponse
            {
                ThisWeekVisits = thisWeekVisits,
                LastWeekVisits = lastWeekVisits,
                WeekChangePct = CalculateChangePct(thisWeekVisits, lastWeekVisits),

                ThisMonthRevenue = monthOrderRevenue + thisMonthMembershipRevenue,
                LastMonthRevenue = lastMonthOrderRevenue + lastMonthMembershipRevenue,
                MonthChangePct = CalculateChangePct(monthOrderRevenue + thisMonthMembershipRevenue, lastMonthOrderRevenue + lastMonthMembershipRevenue),

                ActiveMemberships = activeMemberships,
                ExpiringThisWeekCount = expiringThisWeekCount,
                TodayCheckIns = todayCheckIns,
                Last30DaysCheckIns = last30DaysCheckIns,
                AvgDailyCheckIns = avgDailyCheckIns,
                VisitsByWeekday = visitsByWeekday,

                BestsellerLast30Days = bestseller == null
                    ? null
                    : new BestSellerResponse
                    {
                        SupplementId = bestseller.SupplementId,
                        Name = bestseller.Name,
                        QuantitySold = bestseller.Quantity
                    },

                SlowestMovingLast30Days = worstSeller == null
                    ? null
                    : new SlowestMovingResponse
                    {
                        SupplementId = worstSeller.SupplementId,
                        Name = worstSeller.Name,
                        QuantitySold = worstSeller.Quantity,
                        DaysSinceLastSale = (int)(now - worstSeller.LastSaleDate).TotalDays
                    },

                PopularMembership = popularMembership == null
                    ? null
                    : new PopularMembershipResponse
                    {
                        MembershipPackageId = popularMembership.MembershipPackageId,
                        PackageName = popularMembership.PackageName,
                        PurchaseCount = popularMembership.PurchaseCount
                    },

                ThisMonthVisits = thisMonthVisits,
                BusiestDay = busiestDayData == null ? null : new BusiestDayResponse
                {
                    Date = busiestDayData.Date,
                    VisitCount = busiestDayData.Count
                },

                DailySales = dailySales,
                RevenueBreakdown = revenueBreakdown,
                CheckInHeatmap = checkInHeatmap,
                DailyVisits = dailyVisits,
                MostActivePackage = mostActivePackage == null ? null : new MostActivePackageResponse
                {
                    PackageName = mostActivePackage.PackageName,
                    VisitCount = mostActivePackage.VisitCount
                },
                GrowthRate = new GrowthRateResponse { GrowthPct = growthPct, PeriodDays = 30 }
            };
        }

        public async Task<InventoryReportResponse> GetInventoryReportAsync(int daysToAnalyze = 30)
        {
            var now = DateTime.UtcNow;
            var since = now.AddDays(-daysToAnalyze);

            var allProducts = await _context.Supplements
                .AsNoTracking()
                .Where(s => !s.IsDeleted)
                .Select(s => new
                {
                    s.Id,
                    s.Name,
                    CategoryName = s.SupplementCategory.Name,
                    s.Price
                })
                .ToListAsync();

            // Combined query: period sales + all-time last sale date in one pass
            var salesData = await _context.OrderItems
                .AsNoTracking()
                .Where(oi => !oi.IsDeleted && !oi.Order.IsDeleted)
                .GroupBy(oi => oi.SupplementId)
                .Select(g => new
                {
                    SupplementId = g.Key,
                    QuantitySold = g.Where(x => x.Order.PurchaseDate >= since && x.Order.PurchaseDate <= now).Sum(x => x.Quantity),
                    LastSaleDate = g.Max(x => x.Order.PurchaseDate)
                })
                .ToListAsync();

            var salesDict = salesData.ToDictionary(x => x.SupplementId, x => (x.QuantitySold, x.LastSaleDate));

            var slowMovingProducts = allProducts
                .Select(p =>
                {
                    salesDict.TryGetValue(p.Id, out var data);
                    var daysSinceLastSale = data.LastSaleDate == default ? daysToAnalyze : (int)(now - data.LastSaleDate).TotalDays;

                    return new SlowMovingProductResponse
                    {
                        SupplementId = p.Id,
                        Name = p.Name,
                        CategoryName = p.CategoryName,
                        Price = p.Price,
                        QuantitySold = data.QuantitySold,
                        DaysSinceLastSale = daysSinceLastSale
                    };
                })
                .Where(p => p.QuantitySold <= 2)
                .OrderBy(p => p.QuantitySold)
                .ThenByDescending(p => p.DaysSinceLastSale)
                .ToList();

            return new InventoryReportResponse
            {
                SlowMovingProducts = slowMovingProducts,
                TotalProducts = allProducts.Count,
                SlowMovingCount = slowMovingProducts.Count,
                DaysAnalyzed = daysToAnalyze
            };
        }

        public async Task<InventorySummaryResponse> GetInventorySummaryAsync(int daysToAnalyze = 30)
        {
            var now = DateTime.UtcNow;
            var since = now.AddDays(-daysToAnalyze);

            var salesData = await _context.OrderItems
                .AsNoTracking()
                .Where(oi => !oi.IsDeleted &&
                             !oi.Order.IsDeleted &&
                             oi.Order.PurchaseDate >= since &&
                             oi.Order.PurchaseDate <= now)
                .GroupBy(oi => oi.SupplementId)
                .Select(g => new
                {
                    SupplementId = g.Key,
                    QuantitySold = g.Sum(x => x.Quantity)
                })
                .ToListAsync();

            var salesDict = salesData.ToDictionary(x => x.SupplementId, x => x.QuantitySold);

            // Single query for product IDs — use Count for totalProducts instead of separate CountAsync
            var allProductIds = await _context.Supplements
                .AsNoTracking()
                .Where(s => !s.IsDeleted)
                .Select(s => s.Id)
                .ToListAsync();

            var totalProducts = allProductIds.Count;
            var slowMovingCount = allProductIds.Count(id => !salesDict.ContainsKey(id) || salesDict[id] <= 2);

            return new InventorySummaryResponse
            {
                TotalProducts = totalProducts,
                SlowMovingCount = slowMovingCount,
                DaysAnalyzed = daysToAnalyze
            };
        }

        public async Task<PagedResult<SlowMovingProductResponse>> GetSlowMovingProductsPagedAsync(SlowMovingProductQueryFilter filter)
        {
            var now = DateTime.UtcNow;
            var since = now.AddDays(-filter.DaysToAnalyze);

            var allProducts = await _context.Supplements
                .AsNoTracking()
                .Where(s => !s.IsDeleted)
                .Select(s => new
                {
                    s.Id,
                    s.Name,
                    CategoryName = s.SupplementCategory.Name,
                    s.Price
                })
                .ToListAsync();

            // Combined query: period sales + all-time last sale date in one pass
            var salesData = await _context.OrderItems
                .AsNoTracking()
                .Where(oi => !oi.IsDeleted && !oi.Order.IsDeleted)
                .GroupBy(oi => oi.SupplementId)
                .Select(g => new
                {
                    SupplementId = g.Key,
                    QuantitySold = g.Where(x => x.Order.PurchaseDate >= since && x.Order.PurchaseDate <= now).Sum(x => x.Quantity),
                    LastSaleDate = g.Max(x => x.Order.PurchaseDate)
                })
                .ToListAsync();

            var salesDict = salesData.ToDictionary(x => x.SupplementId, x => (x.QuantitySold, x.LastSaleDate));

            var slowMovingProducts = allProducts
                .Select(p =>
                {
                    salesDict.TryGetValue(p.Id, out var data);
                    var daysSinceLastSale = data.LastSaleDate == default ? filter.DaysToAnalyze : (int)(now - data.LastSaleDate).TotalDays;

                    return new SlowMovingProductResponse
                    {
                        SupplementId = p.Id,
                        Name = p.Name,
                        CategoryName = p.CategoryName,
                        Price = p.Price,
                        QuantitySold = data.QuantitySold,
                        DaysSinceLastSale = daysSinceLastSale
                    };
                })
                .Where(p => p.QuantitySold <= 2)
                .AsQueryable();

            // Apply search filter
            if (!string.IsNullOrWhiteSpace(filter.Search))
            {
                var searchLower = filter.Search.Trim().ToLower();
                slowMovingProducts = slowMovingProducts.Where(p =>
                    p.Name.ToLower().Contains(searchLower) ||
                    p.CategoryName.ToLower().Contains(searchLower));
            }

            // Apply ordering
            var orderBy = filter.OrderBy?.Trim().ToLower();
            slowMovingProducts = orderBy switch
            {
                "name" => slowMovingProducts.OrderBy(p => p.Name),
                "namedesc" => slowMovingProducts.OrderByDescending(p => p.Name),
                "category" => slowMovingProducts.OrderBy(p => p.CategoryName).ThenBy(p => p.Name),
                "categorydesc" => slowMovingProducts.OrderByDescending(p => p.CategoryName).ThenBy(p => p.Name),
                "price" => slowMovingProducts.OrderBy(p => p.Price),
                "pricedesc" => slowMovingProducts.OrderByDescending(p => p.Price),
                "quantitysold" => slowMovingProducts.OrderBy(p => p.QuantitySold).ThenByDescending(p => p.DaysSinceLastSale),
                "quantitysolddesc" => slowMovingProducts.OrderByDescending(p => p.QuantitySold).ThenByDescending(p => p.DaysSinceLastSale),
                "dayssincelastsale" => slowMovingProducts.OrderBy(p => p.DaysSinceLastSale),
                "dayssincelastsaledesc" => slowMovingProducts.OrderByDescending(p => p.DaysSinceLastSale),
                _ => slowMovingProducts.OrderBy(p => p.QuantitySold).ThenByDescending(p => p.DaysSinceLastSale)
            };

            var totalCount = slowMovingProducts.Count();
            var items = slowMovingProducts
                .Skip((filter.PageNumber - 1) * filter.PageSize)
                .Take(filter.PageSize)
                .ToList();

            return new PagedResult<SlowMovingProductResponse>
            {
                Items = items,
                TotalCount = totalCount,
                PageNumber = filter.PageNumber
            };
        }

        public async Task<MembershipPopularityReportResponse> GetMembershipPopularityReportAsync(int days = 90)
        {
            var now = DateTime.UtcNow;
            var last30Days = now.AddDays(-30);
            var revenueWindow = now.AddDays(-days);

            var packages = await _context.MembershipPackages
                .AsNoTracking()
                .Where(p => !p.IsDeleted)
                .Select(p => new
                {
                    p.Id,
                    p.PackageName,
                    p.PackagePrice
                })
                .ToListAsync();

            var activeSubscriptions = await _context.Memberships
                .AsNoTracking()
                .Where(m => !m.IsDeleted && m.StartDate <= now && m.EndDate >= now)
                .GroupBy(m => m.MembershipPackageId)
                .Select(g => new
                {
                    MembershipPackageId = g.Key,
                    Count = g.Count()
                })
                .ToListAsync();

            var newSubscriptionsLast30Days = await _context.Memberships
                .AsNoTracking()
                .Where(m => !m.IsDeleted && m.StartDate >= last30Days && m.StartDate <= now)
                .GroupBy(m => m.MembershipPackageId)
                .Select(g => new
                {
                    MembershipPackageId = g.Key,
                    Count = g.Count()
                })
                .ToListAsync();

            var revenueLast90Days = await _context.MembershipPaymentHistory
                .AsNoTracking()
                .Where(p => !p.IsDeleted && p.PaymentDate >= revenueWindow && p.PaymentDate <= now)
                .GroupBy(p => p.MembershipPackageId)
                .Select(g => new
                {
                    MembershipPackageId = g.Key,
                    Revenue = g.Sum(x => x.AmountPaid)
                })
                .ToListAsync();

            var activeDict = activeSubscriptions.ToDictionary(x => x.MembershipPackageId, x => x.Count);
            var newSubsDict = newSubscriptionsLast30Days.ToDictionary(x => x.MembershipPackageId, x => x.Count);
            var revenueDict = revenueLast90Days.ToDictionary(x => x.MembershipPackageId, x => x.Revenue);

            var totalActive = activeDict.Values.Sum();

            var planStats = packages
                .Select(p =>
                {
                    activeDict.TryGetValue(p.Id, out var active);
                    newSubsDict.TryGetValue(p.Id, out var newSubs);
                    revenueDict.TryGetValue(p.Id, out var revenue);

                    return new MembershipPlanStatsResponse
                    {
                        MembershipPackageId = p.Id,
                        PackageName = p.PackageName,
                        PackagePrice = p.PackagePrice,
                        ActiveSubscriptions = active,
                        NewSubscriptionsLast30Days = newSubs,
                        RevenueLast90Days = revenue,
                        PopularityPercentage = totalActive > 0
                            ? Math.Round((active / (decimal)totalActive) * 100, 2)
                            : 0m
                    };
                })
                .OrderByDescending(p => p.ActiveSubscriptions)
                .ToList();

            return new MembershipPopularityReportResponse
            {
                PlanStats = planStats,
                TotalActiveMemberships = totalActive,
                TotalRevenueLast90Days = revenueDict.Values.Sum()
            };
        }

        public async Task<List<ActivityFeedItemResponse>> GetActivityFeedAsync(int count = 20)
        {
            var feed = new List<ActivityFeedItemResponse>();

            // Recent orders
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

            // Recent user registrations
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

            // Recent memberships
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

            // Sort all combined and take the requested count
            return feed
                .OrderByDescending(f => f.Timestamp)
                .Take(count)
                .ToList();
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

        private static List<WeekdayVisitsResponse> BuildWeekdayVisits(List<WeekdayVisitsResponse> raw)
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

            var result = new List<WeekdayVisitsResponse>(7);

            foreach (var day in orderedDays)
            {
                map.TryGetValue(day, out var count);
                result.Add(new WeekdayVisitsResponse { Day = day, Count = count });
            }

            return result;
        }

        public async Task<StaffReportResponse> GetStaffReportAsync(int days = 30)
        {
            var since = DateTime.UtcNow.AddDays(-days).Date;

            // ── Total staff counts ──
            var totalTrainers = await _context.Trainers
                .AsNoTracking()
                .Where(t => !t.IsDeleted)
                .CountAsync();

            var totalNutritionists = await _context.Nutritionists
                .AsNoTracking()
                .Where(n => !n.IsDeleted)
                .CountAsync();

            // ── Appointment counts (SQL aggregation) ──
            var baseQuery = _context.Appointments
                .AsNoTracking()
                .Where(a => !a.IsDeleted && a.AppointmentDate >= since);

            var trainerAppointments = await baseQuery
                .Where(a => a.TrainerId != null)
                .CountAsync();

            var nutritionistAppointments = await baseQuery
                .Where(a => a.NutritionistId != null)
                .CountAsync();

            // ── Staff ranking (SQL GROUP BY) ──
            var trainerRanking = await baseQuery
                .Where(a => a.TrainerId != null)
                .GroupBy(a => new { a.TrainerId, a.Trainer!.FirstName, a.Trainer.LastName })
                .Select(g => new StaffRankingItemResponse
                {
                    Name = g.Key.FirstName + " " + g.Key.LastName,
                    AppointmentCount = g.Count(),
                    Type = "Trener",
                })
                .OrderByDescending(x => x.AppointmentCount)
                .ToListAsync();

            var nutritionistRanking = await baseQuery
                .Where(a => a.NutritionistId != null)
                .GroupBy(a => new { a.NutritionistId, a.Nutritionist!.FirstName, a.Nutritionist.LastName })
                .Select(g => new StaffRankingItemResponse
                {
                    Name = g.Key.FirstName + " " + g.Key.LastName,
                    AppointmentCount = g.Count(),
                    Type = "Nutricionista",
                })
                .OrderByDescending(x => x.AppointmentCount)
                .ToListAsync();

            var staffRanking = trainerRanking
                .Concat(nutritionistRanking)
                .OrderByDescending(x => x.AppointmentCount)
                .ToList();

            return new StaffReportResponse
            {
                TotalAppointments = trainerAppointments + nutritionistAppointments,
                TrainerAppointments = trainerAppointments,
                NutritionistAppointments = nutritionistAppointments,
                TotalTrainers = totalTrainers,
                TotalNutritionists = totalNutritionists,
                StaffRanking = staffRanking,
            };
        }

        // ── Dashboard sales (lightweight — single SQL query) ──

        public async Task<DashboardSalesResponse> GetDashboardSalesAsync()
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

        public async Task<DashboardAttentionResponse> GetDashboardAttentionAsync(int days = 7)
        {
            var now = DateTime.UtcNow;
            var cutoff = now.AddDays(days);

            var pendingOrdersTask = _context.Orders
                .AsNoTracking()
                .Where(o => !o.IsDeleted && o.Status == OrderStatus.Processing)
                .CountAsync();

            var expiringMembershipsTask = _context.Memberships
                .AsNoTracking()
                .Where(m => !m.IsDeleted && m.StartDate <= now && m.EndDate > now && m.EndDate <= cutoff)
                .CountAsync();

            await Task.WhenAll(pendingOrdersTask, expiringMembershipsTask);

            return new DashboardAttentionResponse
            {
                PendingOrdersCount = pendingOrdersTask.Result,
                ExpiringMembershipsCount = expiringMembershipsTask.Result,
                WindowDays = days,
            };
        }
    }
}
