using ClosedXML.Excel;
using Microsoft.EntityFrameworkCore;
using QuestPDF.Fluent;
using QuestPDF.Helpers;
using QuestPDF.Infrastructure;
using Stronghold.Application.Common;
using Stronghold.Application.DTOs.Response;
using Stronghold.Application.Filters;
using Stronghold.Application.IServices;
using Stronghold.Infrastructure.Data;


namespace Stronghold.Infrastructure.Services
{
    public class ReportService : IReportService
    {
        private readonly StrongholdDbContext _context;

        static ReportService()
        {
            QuestPDF.Settings.License = LicenseType.Community;
        }

        public ReportService(StrongholdDbContext context)
        {
            _context = context;
        }

        public async Task<BusinessReportResponse> GetBusinessReportAsync()
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
                .Select(g => new WeekdayVisitsResponse
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

            // Daily sales breakdown (last 30 days)
            var dailyOrderData = await _context.Orders
                .AsNoTracking()
                .Where(o => o.PurchaseDate >= since && o.PurchaseDate <= now)
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

            // Revenue breakdown (today / this week / this month)
            var todayStart = now.Date;
            var todayEnd = todayStart.AddDays(1);

            var todayOrderRevenue = await _context.Orders
                .AsNoTracking()
                .Where(o => o.PurchaseDate >= todayStart && o.PurchaseDate < todayEnd)
                .SumAsync(o => (decimal?)o.TotalAmount) ?? 0m;

            var todayMembershipRevenue = await _context.MembershipPaymentHistory
                .AsNoTracking()
                .Where(p => p.PaymentDate >= todayStart && p.PaymentDate < todayEnd)
                .SumAsync(p => (decimal?)p.AmountPaid) ?? 0m;

            var weekOrderRevenue = await _context.Orders
                .AsNoTracking()
                .Where(o => o.PurchaseDate >= startOfWeek && o.PurchaseDate < startOfNextWeek)
                .SumAsync(o => (decimal?)o.TotalAmount) ?? 0m;

            var weekMembershipRevenue = await _context.MembershipPaymentHistory
                .AsNoTracking()
                .Where(p => p.PaymentDate >= startOfWeek && p.PaymentDate < startOfNextWeek)
                .SumAsync(p => (decimal?)p.AmountPaid) ?? 0m;

            var monthOrderRevenue = await _context.Orders
                .AsNoTracking()
                .Where(o => o.PurchaseDate >= startOfMonth && o.PurchaseDate < startOfNextMonth)
                .SumAsync(o => (decimal?)o.TotalAmount) ?? 0m;

            var todayOrderCount = await _context.Orders
                .AsNoTracking()
                .Where(o => o.PurchaseDate >= todayStart && o.PurchaseDate < todayEnd)
                .CountAsync();

            // Average order value (this month)
            var monthOrderCount = await _context.Orders
                .AsNoTracking()
                .Where(o => o.PurchaseDate >= startOfMonth && o.PurchaseDate < startOfNextMonth)
                .CountAsync();

            var monthTotalOrderRevenue = monthOrderRevenue;
            var avgOrderValue = monthOrderCount > 0 ? Math.Round(monthTotalOrderRevenue / monthOrderCount, 2) : 0m;

            var revenueBreakdown = new RevenueBreakdownResponse
            {
                TodayRevenue = todayOrderRevenue + todayMembershipRevenue,
                ThisWeekRevenue = weekOrderRevenue + weekMembershipRevenue,
                ThisMonthRevenue = monthOrderRevenue + thisMonthRevenue,
                AverageOrderValue = avgOrderValue,
                TodayOrderCount = todayOrderCount
            };

            return new BusinessReportResponse
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
                    : new BestSellerResponse
                    {
                        SupplementId = bestseller.SupplementId,
                        Name = bestseller.Name,
                        QuantitySold = bestseller.Quantity
                    },

                DailySales = dailySales,
                RevenueBreakdown = revenueBreakdown
            };
        }

        public async Task<InventoryReportResponse> GetInventoryReportAsync(int daysToAnalyze = 30)
        {
            var now = DateTime.UtcNow;
            var since = now.AddDays(-daysToAnalyze);

            var allProducts = await _context.Supplements
                .AsNoTracking()
                .Include(s => s.SupplementCategory)
                .Where(s => !s.IsDeleted)
                .Select(s => new
                {
                    s.Id,
                    s.Name,
                    CategoryName = s.SupplementCategory.Name,
                    s.Price
                })
                .ToListAsync();

            var salesData = await _context.OrderItems
                .AsNoTracking()
                .Where(oi => oi.Order.PurchaseDate >= since && oi.Order.PurchaseDate <= now)
                .GroupBy(oi => oi.SupplementId)
                .Select(g => new
                {
                    SupplementId = g.Key,
                    QuantitySold = g.Sum(x => x.Quantity)
                })
                .ToListAsync();

            var lastSaleDates = await _context.OrderItems
                .AsNoTracking()
                .GroupBy(oi => oi.SupplementId)
                .Select(g => new
                {
                    SupplementId = g.Key,
                    LastSaleDate = g.Max(x => x.Order.PurchaseDate)
                })
                .ToListAsync();

            var salesDict = salesData.ToDictionary(x => x.SupplementId, x => x.QuantitySold);
            var lastSaleDict = lastSaleDates.ToDictionary(x => x.SupplementId, x => x.LastSaleDate);

            var slowMovingProducts = allProducts
                .Select(p =>
                {
                    salesDict.TryGetValue(p.Id, out var qty);
                    lastSaleDict.TryGetValue(p.Id, out var lastSale);
                    var daysSinceLastSale = lastSale == default ? daysToAnalyze : (int)(now - lastSale).TotalDays;

                    return new SlowMovingProductResponse
                    {
                        SupplementId = p.Id,
                        Name = p.Name,
                        CategoryName = p.CategoryName,
                        Price = p.Price,
                        QuantitySold = qty,
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

            var totalProducts = await _context.Supplements
                .AsNoTracking()
                .Where(s => !s.IsDeleted)
                .CountAsync();

            var salesData = await _context.OrderItems
                .AsNoTracking()
                .Where(oi => oi.Order.PurchaseDate >= since && oi.Order.PurchaseDate <= now)
                .GroupBy(oi => oi.SupplementId)
                .Select(g => new
                {
                    SupplementId = g.Key,
                    QuantitySold = g.Sum(x => x.Quantity)
                })
                .ToListAsync();

            var salesDict = salesData.ToDictionary(x => x.SupplementId, x => x.QuantitySold);

            // Count products with <= 2 sales (slow moving) - done in memory
            // because EF Core can't translate Dictionary.ContainsKey to SQL
            var allProductIds = await _context.Supplements
                .AsNoTracking()
                .Where(s => !s.IsDeleted)
                .Select(s => s.Id)
                .ToListAsync();

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
                .Include(s => s.SupplementCategory)
                .Where(s => !s.IsDeleted)
                .Select(s => new
                {
                    s.Id,
                    s.Name,
                    CategoryName = s.SupplementCategory.Name,
                    s.Price
                })
                .ToListAsync();

            var salesData = await _context.OrderItems
                .AsNoTracking()
                .Where(oi => oi.Order.PurchaseDate >= since && oi.Order.PurchaseDate <= now)
                .GroupBy(oi => oi.SupplementId)
                .Select(g => new
                {
                    SupplementId = g.Key,
                    QuantitySold = g.Sum(x => x.Quantity)
                })
                .ToListAsync();

            var lastSaleDates = await _context.OrderItems
                .AsNoTracking()
                .GroupBy(oi => oi.SupplementId)
                .Select(g => new
                {
                    SupplementId = g.Key,
                    LastSaleDate = g.Max(x => x.Order.PurchaseDate)
                })
                .ToListAsync();

            var salesDict = salesData.ToDictionary(x => x.SupplementId, x => x.QuantitySold);
            var lastSaleDict = lastSaleDates.ToDictionary(x => x.SupplementId, x => x.LastSaleDate);

            var slowMovingProducts = allProducts
                .Select(p =>
                {
                    salesDict.TryGetValue(p.Id, out var qty);
                    lastSaleDict.TryGetValue(p.Id, out var lastSale);
                    var daysSinceLastSale = lastSale == default ? filter.DaysToAnalyze : (int)(now - lastSale).TotalDays;

                    return new SlowMovingProductResponse
                    {
                        SupplementId = p.Id,
                        Name = p.Name,
                        CategoryName = p.CategoryName,
                        Price = p.Price,
                        QuantitySold = qty,
                        DaysSinceLastSale = daysSinceLastSale
                    };
                })
                .Where(p => p.QuantitySold <= 2)
                .AsQueryable();

            // Apply search filter
            if (!string.IsNullOrEmpty(filter.Search))
            {
                var searchLower = filter.Search.ToLower();
                slowMovingProducts = slowMovingProducts.Where(p =>
                    p.Name.ToLower().Contains(searchLower) ||
                    p.CategoryName.ToLower().Contains(searchLower));
            }

            // Apply ordering
            slowMovingProducts = filter.OrderBy?.ToLower() switch
            {
                "name" => slowMovingProducts.OrderBy(p => p.Name),
                "namedesc" => slowMovingProducts.OrderByDescending(p => p.Name),
                "price" => slowMovingProducts.OrderBy(p => p.Price),
                "pricedesc" => slowMovingProducts.OrderByDescending(p => p.Price),
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

        public async Task<MembershipPopularityReportResponse> GetMembershipPopularityReportAsync()
        {
            var now = DateTime.UtcNow;
            var last30Days = now.AddDays(-30);
            var last90Days = now.AddDays(-90);

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
                .Where(p => !p.IsDeleted && p.PaymentDate >= last90Days && p.PaymentDate <= now)
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
                .Include(o => o.User)
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
                .Include(m => m.User)
                .Include(m => m.MembershipPackage)
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

        public async Task<byte[]> ExportToExcelAsync()
        {
            var report = await GetBusinessReportAsync();

            using var workbook = new XLWorkbook();
            var worksheet = workbook.Worksheets.Add("Biznis Izvještaj");

            // Title
            worksheet.Cell("A1").Value = "STRONGHOLD - Biznis Izvještaj";
            worksheet.Cell("A1").Style.Font.Bold = true;
            worksheet.Cell("A1").Style.Font.FontSize = 16;
            worksheet.Range("A1:C1").Merge();

            worksheet.Cell("A2").Value = $"Datum generisanja: {DateTime.Now:dd.MM.yyyy HH:mm}";
            worksheet.Range("A2:C2").Merge();

            // Monthly revenue section
            worksheet.Cell("A4").Value = "MJESEČNA PRODAJA";
            worksheet.Cell("A4").Style.Font.Bold = true;

            worksheet.Cell("A5").Value = "Prihod ovog mjeseca:";
            worksheet.Cell("B5").Value = $"{report.ThisMonthRevenue:F2} KM";

            worksheet.Cell("A6").Value = "Prihod prošlog mjeseca:";
            worksheet.Cell("B6").Value = $"{report.LastMonthRevenue:F2} KM";

            worksheet.Cell("A7").Value = "Promjena (%):";
            worksheet.Cell("B7").Value = $"{report.MonthChangePct:F2}%";

            // Revenue breakdown
            worksheet.Cell("A9").Value = "PREGLED PRIHODA";
            worksheet.Cell("A9").Style.Font.Bold = true;

            if (report.RevenueBreakdown != null)
            {
                worksheet.Cell("A10").Value = "Prihod danas:";
                worksheet.Cell("B10").Value = $"{report.RevenueBreakdown.TodayRevenue:F2} KM";

                worksheet.Cell("A11").Value = "Prihod ove sedmice:";
                worksheet.Cell("B11").Value = $"{report.RevenueBreakdown.ThisWeekRevenue:F2} KM";

                worksheet.Cell("A12").Value = "Prihod ovog mjeseca:";
                worksheet.Cell("B12").Value = $"{report.RevenueBreakdown.ThisMonthRevenue:F2} KM";

                worksheet.Cell("A13").Value = "Prosječna vrijednost narudžbe:";
                worksheet.Cell("B13").Value = $"{report.RevenueBreakdown.AverageOrderValue:F2} KM";

                worksheet.Cell("A14").Value = "Narudžbi danas:";
                worksheet.Cell("B14").Value = report.RevenueBreakdown.TodayOrderCount;
            }

            // Bestseller
            worksheet.Cell("A16").Value = "BESTSELLER (POSLJEDNJIH 30 DANA)";
            worksheet.Cell("A16").Style.Font.Bold = true;

            if (report.BestsellerLast30Days != null)
            {
                worksheet.Cell("A17").Value = "Naziv:";
                worksheet.Cell("B17").Value = report.BestsellerLast30Days.Name;

                worksheet.Cell("A18").Value = "Prodato jedinica:";
                worksheet.Cell("B18").Value = report.BestsellerLast30Days.QuantitySold;
            }
            else
            {
                worksheet.Cell("A17").Value = "Nema podataka";
            }

            // Daily sales breakdown
            var row = 20;
            worksheet.Cell($"A{row}").Value = "DNEVNA PRODAJA (POSLJEDNJIH 30 DANA)";
            worksheet.Cell($"A{row}").Style.Font.Bold = true;

            if (report.DailySales != null && report.DailySales.Any())
            {
                row++;
                worksheet.Cell($"A{row}").Value = "Datum";
                worksheet.Cell($"A{row}").Style.Font.Bold = true;
                worksheet.Cell($"B{row}").Value = "Prihod (KM)";
                worksheet.Cell($"B{row}").Style.Font.Bold = true;
                worksheet.Cell($"C{row}").Value = "Broj narudžbi";
                worksheet.Cell($"C{row}").Style.Font.Bold = true;

                foreach (var sale in report.DailySales)
                {
                    row++;
                    worksheet.Cell($"A{row}").Value = sale.Date.ToString("dd.MM.yyyy");
                    worksheet.Cell($"B{row}").Value = $"{sale.Revenue:F2}";
                    worksheet.Cell($"C{row}").Value = sale.OrderCount;
                }
            }

            // Auto-fit columns
            worksheet.Columns().AdjustToContents();

            using var stream = new MemoryStream();
            workbook.SaveAs(stream);
            return stream.ToArray();
        }

        public async Task<byte[]> ExportToPdfAsync()
        {
            var report = await GetBusinessReportAsync();

            var document = Document.Create(container =>
            {
                container.Page(page =>
                {
                    page.Size(PageSizes.A4);
                    page.Margin(40);
                    page.DefaultTextStyle(x => x.FontSize(11));

                    page.Header().Column(col =>
                    {
                        col.Item().Text("STRONGHOLD").Bold().FontSize(24).FontColor(Colors.Red.Darken2);
                        col.Item().Text("Biznis Izvještaj").FontSize(16).FontColor(Colors.Grey.Darken2);
                        col.Item().PaddingTop(5).Text($"Datum: {DateTime.Now:dd.MM.yyyy HH:mm}").FontSize(10).FontColor(Colors.Grey.Medium);
                        col.Item().PaddingTop(10).LineHorizontal(1).LineColor(Colors.Grey.Lighten2);
                    });

                    page.Content().PaddingVertical(20).Column(col =>
                    {
                        // Monthly revenue
                        col.Item().Text("Mjesečna prodaja").Bold().FontSize(14);
                        col.Item().PaddingTop(10).Table(table =>
                        {
                            table.ColumnsDefinition(columns =>
                            {
                                columns.RelativeColumn(2);
                                columns.RelativeColumn(1);
                            });

                            table.Cell().Text("Prihod ovog mjeseca:");
                            table.Cell().Text($"{report.ThisMonthRevenue:F2} KM").Bold();

                            table.Cell().Text("Prihod prošlog mjeseca:");
                            table.Cell().Text($"{report.LastMonthRevenue:F2} KM");

                            table.Cell().Text("Promjena:");
                            var changeColor = report.MonthChangePct >= 0 ? Colors.Green.Darken2 : Colors.Red.Darken2;
                            var changeSign = report.MonthChangePct >= 0 ? "+" : "";
                            table.Cell().Text($"{changeSign}{report.MonthChangePct:F1}%").FontColor(changeColor).Bold();
                        });

                        // Revenue breakdown
                        if (report.RevenueBreakdown != null)
                        {
                            col.Item().PaddingTop(20).Text("Pregled prihoda").Bold().FontSize(14);
                            col.Item().PaddingTop(10).Table(table =>
                            {
                                table.ColumnsDefinition(columns =>
                                {
                                    columns.RelativeColumn(2);
                                    columns.RelativeColumn(1);
                                });

                                table.Cell().Text("Prihod danas:");
                                table.Cell().Text($"{report.RevenueBreakdown.TodayRevenue:F2} KM").Bold();

                                table.Cell().Text("Prihod ove sedmice:");
                                table.Cell().Text($"{report.RevenueBreakdown.ThisWeekRevenue:F2} KM");

                                table.Cell().Text("Prihod ovog mjeseca:");
                                table.Cell().Text($"{report.RevenueBreakdown.ThisMonthRevenue:F2} KM");

                                table.Cell().Text("Prosječna vrijednost narudžbe:");
                                table.Cell().Text($"{report.RevenueBreakdown.AverageOrderValue:F2} KM");

                                table.Cell().Text("Narudžbi danas:");
                                table.Cell().Text($"{report.RevenueBreakdown.TodayOrderCount}").Bold();
                            });
                        }

                        // Bestseller
                        col.Item().PaddingTop(20).Text("Bestseller (posljednjih 30 dana)").Bold().FontSize(14);
                        if (report.BestsellerLast30Days != null)
                        {
                            col.Item().PaddingTop(10).Row(row =>
                            {
                                row.RelativeItem().Column(innerCol =>
                                {
                                    innerCol.Item().Text(report.BestsellerLast30Days.Name).Bold().FontSize(16);
                                    innerCol.Item().Text($"Prodato jedinica: {report.BestsellerLast30Days.QuantitySold}").FontColor(Colors.Grey.Darken1);
                                });
                            });
                        }
                        else
                        {
                            col.Item().PaddingTop(10).Text("Nema podataka").Italic().FontColor(Colors.Grey.Medium);
                        }

                        // Daily sales table
                        if (report.DailySales != null && report.DailySales.Any())
                        {
                            col.Item().PaddingTop(20).Text("Dnevna prodaja (posljednjih 30 dana)").Bold().FontSize(14);
                            col.Item().PaddingTop(10).Table(table =>
                            {
                                table.ColumnsDefinition(columns =>
                                {
                                    columns.RelativeColumn(2);
                                    columns.RelativeColumn(2);
                                    columns.RelativeColumn(1);
                                });

                                table.Header(header =>
                                {
                                    header.Cell().Text("Datum").Bold();
                                    header.Cell().Text("Prihod (KM)").Bold();
                                    header.Cell().Text("Narudžbi").Bold();
                                });

                                foreach (var sale in report.DailySales.Take(30))
                                {
                                    table.Cell().BorderBottom(1).BorderColor(Colors.Grey.Lighten2).Padding(3).Text(sale.Date.ToString("dd.MM.yyyy"));
                                    table.Cell().BorderBottom(1).BorderColor(Colors.Grey.Lighten2).Padding(3).Text($"{sale.Revenue:F2}");
                                    table.Cell().BorderBottom(1).BorderColor(Colors.Grey.Lighten2).Padding(3).Text($"{sale.OrderCount}");
                                }
                            });
                        }
                    });

                    page.Footer().AlignCenter().Text(text =>
                    {
                        text.Span("Stronghold Gym © ").FontColor(Colors.Grey.Medium);
                        text.Span($"{DateTime.Now.Year}").FontColor(Colors.Grey.Medium);
                    });
                });
            });

            return document.GeneratePdf();
        }

        public async Task<byte[]> ExportInventoryReportToExcelAsync(int daysToAnalyze = 30)
        {
            var report = await GetInventoryReportAsync(daysToAnalyze);

            using var workbook = new XLWorkbook();
            var worksheet = workbook.Worksheets.Add("Inventar Izvještaj");

            worksheet.Cell("A1").Value = "STRONGHOLD - Izvještaj o Sporoj Prodaji";
            worksheet.Cell("A1").Style.Font.Bold = true;
            worksheet.Cell("A1").Style.Font.FontSize = 16;
            worksheet.Range("A1:E1").Merge();

            worksheet.Cell("A2").Value = $"Datum generisanja: {DateTime.Now:dd.MM.yyyy HH:mm}";
            worksheet.Range("A2:E2").Merge();

            worksheet.Cell("A3").Value = $"Period analize: posljednjih {report.DaysAnalyzed} dana";
            worksheet.Range("A3:E3").Merge();

            worksheet.Cell("A5").Value = "SAŽETAK";
            worksheet.Cell("A5").Style.Font.Bold = true;

            worksheet.Cell("A6").Value = "Ukupno proizvoda:";
            worksheet.Cell("B6").Value = report.TotalProducts;

            worksheet.Cell("A7").Value = "Proizvodi sa slabom prodajom:";
            worksheet.Cell("B7").Value = report.SlowMovingCount;

            worksheet.Cell("A9").Value = "PROIZVODI SA SLABOM PRODAJOM (≤2 prodaje)";
            worksheet.Cell("A9").Style.Font.Bold = true;
            worksheet.Range("A9:E9").Merge();

            worksheet.Cell("A10").Value = "Naziv";
            worksheet.Cell("B10").Value = "Kategorija";
            worksheet.Cell("C10").Value = "Cijena (KM)";
            worksheet.Cell("D10").Value = "Prodato";
            worksheet.Cell("E10").Value = "Dana od zadnje prodaje";

            var headerRange = worksheet.Range("A10:E10");
            headerRange.Style.Font.Bold = true;
            headerRange.Style.Fill.BackgroundColor = XLColor.LightGray;

            var row = 11;
            foreach (var product in report.SlowMovingProducts)
            {
                worksheet.Cell($"A{row}").Value = product.Name;
                worksheet.Cell($"B{row}").Value = product.CategoryName;
                worksheet.Cell($"C{row}").Value = product.Price;
                worksheet.Cell($"D{row}").Value = product.QuantitySold;
                worksheet.Cell($"E{row}").Value = product.DaysSinceLastSale;
                row++;
            }

            worksheet.Columns().AdjustToContents();

            using var stream = new MemoryStream();
            workbook.SaveAs(stream);
            return stream.ToArray();
        }

        public async Task<byte[]> ExportInventoryReportToPdfAsync(int daysToAnalyze = 30)
        {
            var report = await GetInventoryReportAsync(daysToAnalyze);

            var document = Document.Create(container =>
            {
                container.Page(page =>
                {
                    page.Size(PageSizes.A4);
                    page.Margin(40);
                    page.DefaultTextStyle(x => x.FontSize(11));

                    page.Header().Column(col =>
                    {
                        col.Item().Text("STRONGHOLD").Bold().FontSize(24).FontColor(Colors.Red.Darken2);
                        col.Item().Text("Izvještaj o Sporoj Prodaji").FontSize(16).FontColor(Colors.Grey.Darken2);
                        col.Item().PaddingTop(5).Text($"Datum: {DateTime.Now:dd.MM.yyyy HH:mm}").FontSize(10).FontColor(Colors.Grey.Medium);
                        col.Item().Text($"Period: posljednjih {report.DaysAnalyzed} dana").FontSize(10).FontColor(Colors.Grey.Medium);
                        col.Item().PaddingTop(10).LineHorizontal(1).LineColor(Colors.Grey.Lighten2);
                    });

                    page.Content().PaddingVertical(20).Column(col =>
                    {
                        col.Item().Text("Sažetak").Bold().FontSize(14);
                        col.Item().PaddingTop(10).Table(table =>
                        {
                            table.ColumnsDefinition(columns =>
                            {
                                columns.RelativeColumn(2);
                                columns.RelativeColumn(1);
                            });

                            table.Cell().Text("Ukupno proizvoda:");
                            table.Cell().Text($"{report.TotalProducts}").Bold();

                            table.Cell().Text("Sa slabom prodajom:");
                            table.Cell().Text($"{report.SlowMovingCount}").Bold().FontColor(Colors.Orange.Darken2);
                        });

                        col.Item().PaddingTop(20).Text("Proizvodi sa slabom prodajom (≤2 prodaje)").Bold().FontSize(14);

                        if (report.SlowMovingProducts.Any())
                        {
                            col.Item().PaddingTop(10).Table(table =>
                            {
                                table.ColumnsDefinition(columns =>
                                {
                                    columns.RelativeColumn(3);
                                    columns.RelativeColumn(2);
                                    columns.RelativeColumn(1);
                                    columns.RelativeColumn(1);
                                });

                                table.Header(header =>
                                {
                                    header.Cell().Background(Colors.Grey.Lighten3).Padding(5).Text("Naziv").Bold();
                                    header.Cell().Background(Colors.Grey.Lighten3).Padding(5).Text("Kategorija").Bold();
                                    header.Cell().Background(Colors.Grey.Lighten3).Padding(5).Text("Cijena").Bold();
                                    header.Cell().Background(Colors.Grey.Lighten3).Padding(5).Text("Prodato").Bold();
                                });

                                foreach (var product in report.SlowMovingProducts.Take(20))
                                {
                                    table.Cell().BorderBottom(1).BorderColor(Colors.Grey.Lighten2).Padding(5).Text(product.Name);
                                    table.Cell().BorderBottom(1).BorderColor(Colors.Grey.Lighten2).Padding(5).Text(product.CategoryName);
                                    table.Cell().BorderBottom(1).BorderColor(Colors.Grey.Lighten2).Padding(5).Text($"{product.Price:F2} KM");
                                    table.Cell().BorderBottom(1).BorderColor(Colors.Grey.Lighten2).Padding(5).Text($"{product.QuantitySold}");
                                }
                            });
                        }
                        else
                        {
                            col.Item().PaddingTop(10).Text("Nema proizvoda sa slabom prodajom").Italic().FontColor(Colors.Grey.Medium);
                        }
                    });

                    page.Footer().AlignCenter().Text(text =>
                    {
                        text.Span("Stronghold Gym © ").FontColor(Colors.Grey.Medium);
                        text.Span($"{DateTime.Now.Year}").FontColor(Colors.Grey.Medium);
                    });
                });
            });

            return document.GeneratePdf();
        }

        public async Task<byte[]> ExportMembershipPopularityToExcelAsync()
        {
            var report = await GetMembershipPopularityReportAsync();

            using var workbook = new XLWorkbook();
            var worksheet = workbook.Worksheets.Add("Popularnost Članarina");

            worksheet.Cell("A1").Value = "STRONGHOLD - Popularnost Članarina";
            worksheet.Cell("A1").Style.Font.Bold = true;
            worksheet.Cell("A1").Style.Font.FontSize = 16;
            worksheet.Range("A1:F1").Merge();

            worksheet.Cell("A2").Value = $"Datum generisanja: {DateTime.Now:dd.MM.yyyy HH:mm}";
            worksheet.Cell("A2").Style.Font.Bold = true;
            worksheet.Range("A2:F2").Merge();

            worksheet.Cell("A4").Value = "SAŽETAK";
            worksheet.Cell("A4").Style.Font.Bold = true;

            worksheet.Cell("A5").Value = "Ukupno aktivnih članarina:";
            worksheet.Cell("B5").Value = report.TotalActiveMemberships;

            worksheet.Cell("A6").Value = "Prihod (90 dana):";
            worksheet.Cell("B6").Value = $"{report.TotalRevenueLast90Days:F2} KM";

            worksheet.Cell("A8").Value = "STATISTIKA PO PAKETIMA";
            worksheet.Cell("A8").Style.Font.Bold = true;
            worksheet.Range("A8:F8").Merge();

            worksheet.Cell("A9").Value = "Paket";
            worksheet.Cell("B9").Value = "Cijena (KM)";
            worksheet.Cell("C9").Value = "Aktivne";
            worksheet.Cell("D9").Value = "Novih (30 dana)";
            worksheet.Cell("E9").Value = "Prihod (90 dana)";
            worksheet.Cell("F9").Value = "Popularnost (%)";

            var headerRange = worksheet.Range("A9:F9");
            headerRange.Style.Font.Bold = true;
            headerRange.Style.Fill.BackgroundColor = XLColor.LightGray;

            var row = 10;
            foreach (var plan in report.PlanStats)
            {
                worksheet.Cell($"A{row}").Value = plan.PackageName;
                worksheet.Cell($"B{row}").Value = plan.PackagePrice;
                worksheet.Cell($"C{row}").Value = plan.ActiveSubscriptions;
                worksheet.Cell($"D{row}").Value = plan.NewSubscriptionsLast30Days;
                worksheet.Cell($"E{row}").Value = $"{plan.RevenueLast90Days:F2}";
                worksheet.Cell($"F{row}").Value = $"{plan.PopularityPercentage:F1}%";
                row++;
            }

            worksheet.Columns().AdjustToContents();

            using var stream = new MemoryStream();
            workbook.SaveAs(stream);
            return stream.ToArray();
        }

        public async Task<byte[]> ExportMembershipPopularityToPdfAsync()
        {
            var report = await GetMembershipPopularityReportAsync();

            var document = Document.Create(container =>
            {
                container.Page(page =>
                {
                    page.Size(PageSizes.A4);
                    page.Margin(40);
                    page.DefaultTextStyle(x => x.FontSize(11));

                    page.Header().Column(col =>
                    {
                        col.Item().Text("STRONGHOLD").Bold().FontSize(24).FontColor(Colors.Red.Darken2);
                        col.Item().Text("Popularnost Članarina").FontSize(16).FontColor(Colors.Grey.Darken2);
                        col.Item().PaddingTop(5).Text($"Datum: {DateTime.Now:dd.MM.yyyy HH:mm}").FontSize(10).FontColor(Colors.Grey.Medium);
                        col.Item().PaddingTop(10).LineHorizontal(1).LineColor(Colors.Grey.Lighten2);
                    });

                    page.Content().PaddingVertical(20).Column(col =>
                    {
                        col.Item().Text("Sažetak").Bold().FontSize(14);
                        col.Item().PaddingTop(10).Table(table =>
                        {
                            table.ColumnsDefinition(columns =>
                            {
                                columns.RelativeColumn(2);
                                columns.RelativeColumn(1);
                            });

                            table.Cell().Text("Ukupno aktivnih članarina:");
                            table.Cell().Text($"{report.TotalActiveMemberships}").Bold().FontColor(Colors.Red.Darken2);

                            table.Cell().Text("Prihod (posljednjih 90 dana):");
                            table.Cell().Text($"{report.TotalRevenueLast90Days:F2} KM").Bold();
                        });

                        col.Item().PaddingTop(20).Text("Statistika po paketima").Bold().FontSize(14);

                        if (report.PlanStats.Any())
                        {
                            col.Item().PaddingTop(10).Table(table =>
                            {
                                table.ColumnsDefinition(columns =>
                                {
                                    columns.RelativeColumn(3);
                                    columns.RelativeColumn(1);
                                    columns.RelativeColumn(1);
                                    columns.RelativeColumn(2);
                                });

                                table.Header(header =>
                                {
                                    header.Cell().Background(Colors.Grey.Lighten3).Padding(5).Text("Paket").Bold();
                                    header.Cell().Background(Colors.Grey.Lighten3).Padding(5).Text("Aktivne").Bold();
                                    header.Cell().Background(Colors.Grey.Lighten3).Padding(5).Text("Novih").Bold();
                                    header.Cell().Background(Colors.Grey.Lighten3).Padding(5).Text("Popularnost").Bold();
                                });

                                foreach (var plan in report.PlanStats)
                                {
                                    table.Cell().BorderBottom(1).BorderColor(Colors.Grey.Lighten2).Padding(5).Text(plan.PackageName);
                                    table.Cell().BorderBottom(1).BorderColor(Colors.Grey.Lighten2).Padding(5).Text($"{plan.ActiveSubscriptions}");
                                    table.Cell().BorderBottom(1).BorderColor(Colors.Grey.Lighten2).Padding(5).Text($"{plan.NewSubscriptionsLast30Days}");

                                    var popColor = plan.PopularityPercentage >= 30 ? Colors.Green.Darken2 :
                                                   plan.PopularityPercentage >= 10 ? Colors.Orange.Darken2 :
                                                   Colors.Grey.Darken1;
                                    table.Cell().BorderBottom(1).BorderColor(Colors.Grey.Lighten2).Padding(5)
                                        .Text($"{plan.PopularityPercentage:F1}%").FontColor(popColor).Bold();
                                }
                            });

                            var topPlan = report.PlanStats.FirstOrDefault();
                            if (topPlan != null)
                            {
                                col.Item().PaddingTop(20).Text("Najpopularniji paket").Bold().FontSize(14);
                                col.Item().PaddingTop(10).Row(r =>
                                {
                                    r.RelativeItem().Column(innerCol =>
                                    {
                                        innerCol.Item().Text(topPlan.PackageName).Bold().FontSize(18).FontColor(Colors.Red.Darken2);
                                        innerCol.Item().Text($"Aktivnih: {topPlan.ActiveSubscriptions} | Popularnost: {topPlan.PopularityPercentage:F1}%").FontColor(Colors.Grey.Darken1);
                                        innerCol.Item().Text($"Prihod (90 dana): {topPlan.RevenueLast90Days:F2} KM").FontColor(Colors.Grey.Darken1);
                                    });
                                });
                            }
                        }
                        else
                        {
                            col.Item().PaddingTop(10).Text("Nema podataka o članarinama").Italic().FontColor(Colors.Grey.Medium);
                        }
                    });

                    page.Footer().AlignCenter().Text(text =>
                    {
                        text.Span("Stronghold Gym © ").FontColor(Colors.Grey.Medium);
                        text.Span($"{DateTime.Now.Year}").FontColor(Colors.Grey.Medium);
                    });
                });
            });

            return document.GeneratePdf();
        }
    }
}
