using ClosedXML.Excel;
using Microsoft.EntityFrameworkCore;
using QuestPDF.Fluent;
using QuestPDF.Helpers;
using QuestPDF.Infrastructure;
using Stronghold.Application.DTOs.AdminReportsDTO;
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

            // Weekly visits section
            worksheet.Cell("A4").Value = "SEDMIČNA POSJEĆENOST";
            worksheet.Cell("A4").Style.Font.Bold = true;

            worksheet.Cell("A5").Value = "Posjete ove sedmice:";
            worksheet.Cell("B5").Value = report.ThisWeekVisits;

            worksheet.Cell("A6").Value = "Posjete prošle sedmice:";
            worksheet.Cell("B6").Value = report.LastWeekVisits;

            worksheet.Cell("A7").Value = "Promjena (%):";
            worksheet.Cell("B7").Value = $"{report.WeekChangePct:F2}%";

            // Monthly revenue section
            worksheet.Cell("A9").Value = "MJESEČNA PRODAJA";
            worksheet.Cell("A9").Style.Font.Bold = true;

            worksheet.Cell("A10").Value = "Prihod ovog mjeseca:";
            worksheet.Cell("B10").Value = $"{report.ThisMonthRevenue:F2} KM";

            worksheet.Cell("A11").Value = "Prihod prošlog mjeseca:";
            worksheet.Cell("B11").Value = $"{report.LastMonthRevenue:F2} KM";

            worksheet.Cell("A12").Value = "Promjena (%):";
            worksheet.Cell("B12").Value = $"{report.MonthChangePct:F2}%";

            // Active memberships
            worksheet.Cell("A14").Value = "AKTIVNE ČLANARINE";
            worksheet.Cell("A14").Style.Font.Bold = true;

            worksheet.Cell("A15").Value = "Broj aktivnih članova:";
            worksheet.Cell("B15").Value = report.ActiveMemberships;

            // Visits by weekday
            worksheet.Cell("A17").Value = "POSJETE PO DANIMA U SEDMICI";
            worksheet.Cell("A17").Style.Font.Bold = true;

            var dayNames = new Dictionary<DayOfWeek, string>
            {
                { DayOfWeek.Monday, "Ponedjeljak" },
                { DayOfWeek.Tuesday, "Utorak" },
                { DayOfWeek.Wednesday, "Srijeda" },
                { DayOfWeek.Thursday, "Četvrtak" },
                { DayOfWeek.Friday, "Petak" },
                { DayOfWeek.Saturday, "Subota" },
                { DayOfWeek.Sunday, "Nedjelja" }
            };

            var row = 18;
            foreach (var visit in report.VisitsByWeekday)
            {
                worksheet.Cell($"A{row}").Value = dayNames[visit.Day];
                worksheet.Cell($"B{row}").Value = visit.Count;
                row++;
            }

            // Bestseller
            worksheet.Cell($"A{row + 1}").Value = "BESTSELLER (POSLJEDNJIH 30 DANA)";
            worksheet.Cell($"A{row + 1}").Style.Font.Bold = true;

            if (report.BestsellerLast30Days != null)
            {
                worksheet.Cell($"A{row + 2}").Value = "Naziv:";
                worksheet.Cell($"B{row + 2}").Value = report.BestsellerLast30Days.Name;

                worksheet.Cell($"A{row + 3}").Value = "Prodato jedinica:";
                worksheet.Cell($"B{row + 3}").Value = report.BestsellerLast30Days.QuantitySold;
            }
            else
            {
                worksheet.Cell($"A{row + 2}").Value = "Nema podataka";
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

            var dayNames = new Dictionary<DayOfWeek, string>
            {
                { DayOfWeek.Monday, "Ponedjeljak" },
                { DayOfWeek.Tuesday, "Utorak" },
                { DayOfWeek.Wednesday, "Srijeda" },
                { DayOfWeek.Thursday, "Četvrtak" },
                { DayOfWeek.Friday, "Petak" },
                { DayOfWeek.Saturday, "Subota" },
                { DayOfWeek.Sunday, "Nedjelja" }
            };

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
                        // Weekly visits
                        col.Item().Text("Sedmična posjećenost").Bold().FontSize(14);
                        col.Item().PaddingTop(10).Table(table =>
                        {
                            table.ColumnsDefinition(columns =>
                            {
                                columns.RelativeColumn(2);
                                columns.RelativeColumn(1);
                            });

                            table.Cell().Text("Posjete ove sedmice:");
                            table.Cell().Text($"{report.ThisWeekVisits}").Bold();

                            table.Cell().Text("Posjete prošle sedmice:");
                            table.Cell().Text($"{report.LastWeekVisits}");

                            table.Cell().Text("Promjena:");
                            var changeColor = report.WeekChangePct >= 0 ? Colors.Green.Darken2 : Colors.Red.Darken2;
                            var changeSign = report.WeekChangePct >= 0 ? "↑" : "↓";
                            table.Cell().Text($"{changeSign} {Math.Abs(report.WeekChangePct):F1}%").FontColor(changeColor).Bold();
                        });

                        col.Item().PaddingTop(20).Text("Mjesečna prodaja").Bold().FontSize(14);
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
                            var changeSign = report.MonthChangePct >= 0 ? "↑" : "↓";
                            table.Cell().Text($"{changeSign} {Math.Abs(report.MonthChangePct):F1}%").FontColor(changeColor).Bold();
                        });

                        col.Item().PaddingTop(20).Text("Aktivne članarine").Bold().FontSize(14);
                        col.Item().PaddingTop(10).Text($"Broj aktivnih članova: {report.ActiveMemberships}").Bold().FontSize(18).FontColor(Colors.Red.Darken2);

                        col.Item().PaddingTop(20).Text("Posjete po danima u sedmici").Bold().FontSize(14);
                        col.Item().PaddingTop(10).Table(table =>
                        {
                            table.ColumnsDefinition(columns =>
                            {
                                columns.RelativeColumn(2);
                                columns.RelativeColumn(1);
                            });

                            table.Header(header =>
                            {
                                header.Cell().Text("Dan").Bold();
                                header.Cell().Text("Broj posjeta").Bold();
                            });

                            foreach (var visit in report.VisitsByWeekday)
                            {
                                table.Cell().BorderBottom(1).BorderColor(Colors.Grey.Lighten2).Padding(5).Text(dayNames[visit.Day]);
                                table.Cell().BorderBottom(1).BorderColor(Colors.Grey.Lighten2).Padding(5).Text($"{visit.Count}");
                            }
                        });

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
