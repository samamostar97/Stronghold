using ClosedXML.Excel;
using QuestPDF.Fluent;
using QuestPDF.Helpers;
using QuestPDF.Infrastructure;
using Stronghold.Application.Common;
using Stronghold.Application.IServices;

namespace Stronghold.Infrastructure.Services
{
    public class ReportExportService : IReportExportService
    {
        private readonly IReportReadService _reportReadService;

        static ReportExportService()
        {
            QuestPDF.Settings.License = LicenseType.Community;
        }

        public ReportExportService(IReportReadService reportReadService)
        {
            _reportReadService = reportReadService;
        }

        public async Task<byte[]> ExportToExcelAsync()
        {
            const int days = 30;
            var periodLabel = "posljednjih " + days + " dana";
            var report = await _reportReadService.GetBusinessReportAsync(days);
            using var workbook = new XLWorkbook();
            var worksheet = workbook.Worksheets.Add("Biznis Izvještaj");

            // Title
            worksheet.Cell("A1").Value = "STRONGHOLD - Biznis Izvještaj";
            worksheet.Cell("A1").Style.Font.Bold = true;
            worksheet.Cell("A1").Style.Font.FontSize = 16;
            worksheet.Range("A1:C1").Merge();

            worksheet.Cell("A2").Value = $"Datum generisanja: {StrongholdTimeUtils.LocalNow:dd.MM.yyyy HH:mm}";
            worksheet.Range("A2:C2").Merge();

            // Stat cards section
            worksheet.Cell("A4").Value = "PREGLED";
            worksheet.Cell("A4").Style.Font.Bold = true;

            worksheet.Cell("A5").Value = "Prodaja ovog mjeseca:";
            worksheet.Cell("B5").Value = $"{report.ThisMonthRevenue:F2} KM";

            worksheet.Cell("A6").Value = "Prihod od narudžbi ovaj mjesec:";
            worksheet.Cell("B6").Value = $"{report.RevenueBreakdown?.MonthOrderRevenue:F2} KM";

            worksheet.Cell("A7").Value = "Prosječna narudžba ovaj mjesec:";
            worksheet.Cell("B7").Value = $"{report.RevenueBreakdown?.AverageOrderValue:F2} KM";

            // Revenue breakdown
            worksheet.Cell("A9").Value = "PREGLED PRIHODA";
            worksheet.Cell("A9").Style.Font.Bold = true;

            if (report.RevenueBreakdown != null)
            {
                worksheet.Cell("A10").Value = "Danas:";
                worksheet.Cell("B10").Value = $"{report.RevenueBreakdown.TodayRevenue:F2} KM";

                worksheet.Cell("A11").Value = "Ova sedmica:";
                worksheet.Cell("B11").Value = $"{report.RevenueBreakdown.ThisWeekRevenue:F2} KM";

                worksheet.Cell("A12").Value = "Ovaj mjesec:";
                worksheet.Cell("B12").Value = $"{report.RevenueBreakdown.ThisMonthRevenue:F2} KM";

                worksheet.Cell("A13").Value = "Prosječna narudžba:";
                worksheet.Cell("B13").Value = $"{report.RevenueBreakdown.AverageOrderValue:F2} KM";
            }

            // Bestseller
            worksheet.Cell("A15").Value = $"BESTSELLER ({periodLabel.ToUpper()})";
            worksheet.Cell("A15").Style.Font.Bold = true;

            if (report.BestsellerLast30Days != null)
            {
                worksheet.Cell("A16").Value = "Naziv:";
                worksheet.Cell("B16").Value = report.BestsellerLast30Days.Name;

                worksheet.Cell("A17").Value = "Prodato jedinica:";
                worksheet.Cell("B17").Value = report.BestsellerLast30Days.QuantitySold;
            }
            else
            {
                worksheet.Cell("A16").Value = "Nema podataka";
            }

            // Popular membership
            var pmRow = report.BestsellerLast30Days != null ? 19 : 18;
            worksheet.Cell($"A{pmRow}").Value = "NAJPOPULARNIJA ČLANARINA (ZADNJIH 30 DANA)";
            worksheet.Cell($"A{pmRow}").Style.Font.Bold = true;

            if (report.PopularMembership != null)
            {
                pmRow++;
                worksheet.Cell($"A{pmRow}").Value = "Naziv:";
                worksheet.Cell($"B{pmRow}").Value = report.PopularMembership.PackageName;

                pmRow++;
                worksheet.Cell($"A{pmRow}").Value = "Kupljenih:";
                worksheet.Cell($"B{pmRow}").Value = report.PopularMembership.PurchaseCount;
            }
            else
            {
                pmRow++;
                worksheet.Cell($"A{pmRow}").Value = "Nema podataka";
            }

            // Daily sales breakdown
            var row = pmRow + 2;
            worksheet.Cell($"A{row}").Value = $"DNEVNA PRODAJA ({periodLabel.ToUpper()})";
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
            const int days = 30;
            var periodLabel = "posljednjih " + days + " dana";
            var report = await _reportReadService.GetBusinessReportAsync(days);
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
                        col.Item().PaddingTop(5).Text($"Datum: {StrongholdTimeUtils.LocalNow:dd.MM.yyyy HH:mm}").FontSize(10).FontColor(Colors.Grey.Medium);
                        col.Item().PaddingTop(10).LineHorizontal(1).LineColor(Colors.Grey.Lighten2);
                    });

                    page.Content().PaddingVertical(20).Column(col =>
                    {
                        // Stat cards
                        col.Item().Text("Pregled").Bold().FontSize(14);
                        col.Item().PaddingTop(10).Table(table =>
                        {
                            table.ColumnsDefinition(columns =>
                            {
                                columns.RelativeColumn(2);
                                columns.RelativeColumn(1);
                            });

                            table.Cell().Text("Prodaja ovog mjeseca:");
                            table.Cell().Text($"{report.ThisMonthRevenue:F2} KM").Bold();

                            table.Cell().Text("Prihod od narudžbi ovaj mjesec:");
                            table.Cell().Text($"{report.RevenueBreakdown?.MonthOrderRevenue:F2} KM");

                            table.Cell().Text("Prosječna narudžba ovaj mjesec:");
                            table.Cell().Text($"{report.RevenueBreakdown?.AverageOrderValue:F2} KM");
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

                                table.Cell().Text("Danas:");
                                table.Cell().Text($"{report.RevenueBreakdown.TodayRevenue:F2} KM").Bold();

                                table.Cell().Text("Ova sedmica:");
                                table.Cell().Text($"{report.RevenueBreakdown.ThisWeekRevenue:F2} KM");

                                table.Cell().Text("Ovaj mjesec:");
                                table.Cell().Text($"{report.RevenueBreakdown.ThisMonthRevenue:F2} KM");

                                table.Cell().Text("Prosječna narudžba:");
                                table.Cell().Text($"{report.RevenueBreakdown.AverageOrderValue:F2} KM");
                            });
                        }

                        // Bestseller
                        col.Item().PaddingTop(20).Text($"Bestseller ({periodLabel})").Bold().FontSize(14);
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

                        // Popular membership
                        col.Item().PaddingTop(20).Text("Najpopularnija članarina (zadnjih 30 dana)").Bold().FontSize(14);
                        if (report.PopularMembership != null)
                        {
                            col.Item().PaddingTop(10).Row(row =>
                            {
                                row.RelativeItem().Column(innerCol =>
                                {
                                    innerCol.Item().Text(report.PopularMembership.PackageName).Bold().FontSize(16);
                                    innerCol.Item().Text($"Kupljenih: {report.PopularMembership.PurchaseCount}").FontColor(Colors.Grey.Darken1);
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
                            col.Item().PaddingTop(20).Text($"Dnevna prodaja ({periodLabel})").Bold().FontSize(14);
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
                        text.Span("Stronghold Gym (c) ").FontColor(Colors.Grey.Medium);
                        text.Span($"{StrongholdTimeUtils.LocalNow.Year}").FontColor(Colors.Grey.Medium);
                    });
                });
            });

            return document.GeneratePdf();
        }

        public async Task<byte[]> ExportMembershipPopularityToExcelAsync()
        {
            const int days = 90;
            var periodLabel = "posljednjih " + days + " dana";
            var report = await _reportReadService.GetMembershipPopularityReportAsync(days);
            using var workbook = new XLWorkbook();
            var worksheet = workbook.Worksheets.Add("Popularnost Članarina");

            worksheet.Cell("A1").Value = "STRONGHOLD - Popularnost Članarina";
            worksheet.Cell("A1").Style.Font.Bold = true;
            worksheet.Cell("A1").Style.Font.FontSize = 16;
            worksheet.Range("A1:F1").Merge();

            worksheet.Cell("A2").Value = $"Datum generisanja: {StrongholdTimeUtils.LocalNow:dd.MM.yyyy HH:mm}";
            worksheet.Cell("A2").Style.Font.Bold = true;
            worksheet.Range("A2:F2").Merge();

            worksheet.Cell("A4").Value = "SAŽETAK";
            worksheet.Cell("A4").Style.Font.Bold = true;

            worksheet.Cell("A5").Value = "Ukupno aktivnih članarina:";
            worksheet.Cell("B5").Value = report.TotalActiveMemberships;

            worksheet.Cell("A6").Value = $"Prihod ({periodLabel}):";
            worksheet.Cell("B6").Value = $"{report.TotalRevenueLast90Days:F2} KM";

            worksheet.Cell("A8").Value = "STATISTIKA PO PAKETIMA";
            worksheet.Cell("A8").Style.Font.Bold = true;
            worksheet.Range("A8:F8").Merge();

            worksheet.Cell("A9").Value = "Paket";
            worksheet.Cell("B9").Value = "Cijena (KM)";
            worksheet.Cell("C9").Value = "Aktivne";
            worksheet.Cell("D9").Value = "Novih (30 dana)";
            worksheet.Cell("E9").Value = $"Prihod ({periodLabel})";
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
            const int days = 90;
            var periodLabel = "posljednjih " + days + " dana";
            var report = await _reportReadService.GetMembershipPopularityReportAsync(days);
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
                        col.Item().PaddingTop(5).Text($"Datum: {StrongholdTimeUtils.LocalNow:dd.MM.yyyy HH:mm}").FontSize(10).FontColor(Colors.Grey.Medium);
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

                            table.Cell().Text($"Prihod ({periodLabel}):");
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
                                        innerCol.Item().Text($"Prihod ({periodLabel}): {topPlan.RevenueLast90Days:F2} KM").FontColor(Colors.Grey.Darken1);
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
                        text.Span("Stronghold Gym (c) ").FontColor(Colors.Grey.Medium);
                        text.Span($"{StrongholdTimeUtils.LocalNow.Year}").FontColor(Colors.Grey.Medium);
                    });
                });
            });

            return document.GeneratePdf();
        }

        public async Task<byte[]> ExportVisitsToExcelAsync()
        {
            const int days = 30;
            var periodLabel = "posljednjih " + days + " dana";
            var report = await _reportReadService.GetBusinessReportAsync(days);
            using var workbook = new XLWorkbook();
            var worksheet = workbook.Worksheets.Add("Posjete Izvještaj");

            worksheet.Cell("A1").Value = "STRONGHOLD - Izvještaj Posjeta";
            worksheet.Cell("A1").Style.Font.Bold = true;
            worksheet.Cell("A1").Style.Font.FontSize = 16;
            worksheet.Range("A1:C1").Merge();
            worksheet.Cell("A2").Value = $"Datum generisanja: {StrongholdTimeUtils.LocalNow:dd.MM.yyyy HH:mm}";
            worksheet.Range("A2:C2").Merge();

            // Summary
            worksheet.Cell("A4").Value = "PREGLED POSJETA";
            worksheet.Cell("A4").Style.Font.Bold = true;

            worksheet.Cell("A5").Value = "Posjete u ovom mjesecu:";
            worksheet.Cell("B5").Value = report.ThisMonthVisits;

            worksheet.Cell("A6").Value = "Prosjecno dnevno:";
            worksheet.Cell("B6").Value = $"{report.AvgDailyCheckIns:F1}";

            if (report.BusiestDay != null)
            {
                worksheet.Cell("A7").Value = "Najprometniji dan ovaj mjesec:";
                worksheet.Cell("B7").Value = report.BusiestDay.Date.ToString("dd.MM.yyyy");
                worksheet.Cell("A8").Value = "Posjeta tog dana:";
                worksheet.Cell("B8").Value = report.BusiestDay.VisitCount;
            }

            if (report.MostActivePackage != null)
            {
                var mapRow = report.BusiestDay != null ? 10 : 8;
                worksheet.Cell($"A{mapRow}").Value = "NAJAKTIVNIJI PAKET U OVOM MJESECU";
                worksheet.Cell($"A{mapRow}").Style.Font.Bold = true;
                worksheet.Cell($"A{mapRow + 1}").Value = "Naziv:";
                worksheet.Cell($"B{mapRow + 1}").Value = report.MostActivePackage.PackageName;
                worksheet.Cell($"A{mapRow + 2}").Value = "Posjeta:";
                worksheet.Cell($"B{mapRow + 2}").Value = report.MostActivePackage.VisitCount;
            }

            // Growth rate
            var grRow = 14;
            worksheet.Cell($"A{grRow}").Value = "STOPA RASTA";
            worksheet.Cell($"A{grRow}").Style.Font.Bold = true;
            worksheet.Cell($"A{grRow + 1}").Value = "Promjena:";
            worksheet.Cell($"B{grRow + 1}").Value = $"{(report.GrowthRate.GrowthPct >= 0 ? "+" : "")}{report.GrowthRate.GrowthPct:F1}%";
            worksheet.Cell($"A{grRow + 2}").Value = "Period:";
            worksheet.Cell($"B{grRow + 2}").Value = $"Zadnjih {report.GrowthRate.PeriodDays} dana";

            // Daily visits table
            var row = grRow + 4;
            worksheet.Cell($"A{row}").Value = $"DNEVNE POSJETE ({periodLabel.ToUpper()})";
            worksheet.Cell($"A{row}").Style.Font.Bold = true;

            if (report.DailyVisits != null && report.DailyVisits.Any())
            {
                row++;
                worksheet.Cell($"A{row}").Value = "Datum";
                worksheet.Cell($"A{row}").Style.Font.Bold = true;
                worksheet.Cell($"B{row}").Value = "Broj posjeta";
                worksheet.Cell($"B{row}").Style.Font.Bold = true;

                foreach (var visit in report.DailyVisits)
                {
                    row++;
                    worksheet.Cell($"A{row}").Value = visit.Date.ToString("dd.MM.yyyy");
                    worksheet.Cell($"B{row}").Value = visit.VisitCount;
                }
            }

            worksheet.Columns().AdjustToContents();

            using var stream = new MemoryStream();
            workbook.SaveAs(stream);
            return stream.ToArray();
        }

        public async Task<byte[]> ExportVisitsToPdfAsync()
        {
            const int days = 30;
            var periodLabel = "posljednjih " + days + " dana";
            var report = await _reportReadService.GetBusinessReportAsync(days);
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
                        col.Item().Text("Izvještaj Posjeta").FontSize(16).FontColor(Colors.Grey.Darken2);
                        col.Item().PaddingTop(5).Text($"Datum: {StrongholdTimeUtils.LocalNow:dd.MM.yyyy HH:mm}").FontSize(10).FontColor(Colors.Grey.Medium);
                        col.Item().PaddingTop(10).LineHorizontal(1).LineColor(Colors.Grey.Lighten2);
                    });

                    page.Content().PaddingVertical(20).Column(col =>
                    {
                        // Summary
                        col.Item().Text("Pregled posjeta").Bold().FontSize(14);
                        col.Item().PaddingTop(10).Table(table =>
                        {
                            table.ColumnsDefinition(columns =>
                            {
                                columns.RelativeColumn(2);
                                columns.RelativeColumn(1);
                            });

                            table.Cell().Text("Posjete u ovom mjesecu:");
                            table.Cell().Text($"{report.ThisMonthVisits}").Bold();

                            table.Cell().Text("Prosjecno dnevno:");
                            table.Cell().Text($"{report.AvgDailyCheckIns:F1}");
                        });

                        // Busiest day
                        if (report.BusiestDay != null)
                        {
                            col.Item().PaddingTop(20).Text("Najprometniji dan ovaj mjesec").Bold().FontSize(14);
                            col.Item().PaddingTop(10).Row(r =>
                            {
                                r.RelativeItem().Column(innerCol =>
                                {
                                    innerCol.Item().Text(report.BusiestDay.Date.ToString("dd.MM.yyyy")).Bold().FontSize(16);
                                    innerCol.Item().Text($"{report.BusiestDay.VisitCount} posjeta").FontColor(Colors.Grey.Darken1);
                                });
                            });
                        }

                        // Most active package
                        if (report.MostActivePackage != null)
                        {
                            col.Item().PaddingTop(20).Text("Najaktivniji paket u ovom mjesecu").Bold().FontSize(14);
                            col.Item().PaddingTop(10).Row(r =>
                            {
                                r.RelativeItem().Column(innerCol =>
                                {
                                    innerCol.Item().Text(report.MostActivePackage.PackageName).Bold().FontSize(16);
                                    innerCol.Item().Text($"Ukupno {report.MostActivePackage.VisitCount} posjeta").FontColor(Colors.Grey.Darken1);
                                });
                            });
                        }

                        // Growth rate
                        col.Item().PaddingTop(20).Text("Stopa rasta").Bold().FontSize(14);
                        col.Item().PaddingTop(10).Table(table =>
                        {
                            table.ColumnsDefinition(columns =>
                            {
                                columns.RelativeColumn(2);
                                columns.RelativeColumn(1);
                            });

                            table.Cell().Text("Promjena:");
                            table.Cell().Text($"{(report.GrowthRate.GrowthPct >= 0 ? "+" : "")}{report.GrowthRate.GrowthPct:F1}%").Bold();

                            table.Cell().Text("Period:");
                            table.Cell().Text($"Zadnjih {report.GrowthRate.PeriodDays} dana");
                        });

                        // Daily visits table
                        if (report.DailyVisits != null && report.DailyVisits.Any())
                        {
                            col.Item().PaddingTop(20).Text($"Dnevne posjete ({periodLabel})").Bold().FontSize(14);
                            col.Item().PaddingTop(10).Table(table =>
                            {
                                table.ColumnsDefinition(columns =>
                                {
                                    columns.RelativeColumn(2);
                                    columns.RelativeColumn(1);
                                });

                                table.Header(header =>
                                {
                                    header.Cell().Text("Datum").Bold();
                                    header.Cell().Text("Posjeta").Bold();
                                });

                                foreach (var visit in report.DailyVisits)
                                {
                                    table.Cell().Text(visit.Date.ToString("dd.MM.yyyy"));
                                    table.Cell().Text($"{visit.VisitCount}");
                                }
                            });
                        }
                    });

                    page.Footer().AlignCenter().Text(text =>
                    {
                        text.Span("Stronghold Gym (c) ").FontColor(Colors.Grey.Medium);
                        text.Span($"{StrongholdTimeUtils.LocalNow.Year}").FontColor(Colors.Grey.Medium);
                    });
                });
            });

            return document.GeneratePdf();
        }

        public async Task<byte[]> ExportStaffToExcelAsync()
        {
            const int days = 30;
            var periodLabel = "posljednjih " + days + " dana";
            var report = await _reportReadService.GetStaffReportAsync(days);
            using var workbook = new XLWorkbook();
            var worksheet = workbook.Worksheets.Add("Osoblje Izvještaj");

            worksheet.Cell("A1").Value = "STRONGHOLD - Izvještaj Osoblja";
            worksheet.Cell("A1").Style.Font.Bold = true;
            worksheet.Cell("A1").Style.Font.FontSize = 16;
            worksheet.Range("A1:C1").Merge();
            worksheet.Cell("A2").Value = $"Datum generisanja: {StrongholdTimeUtils.LocalNow:dd.MM.yyyy HH:mm}";
            worksheet.Range("A2:C2").Merge();
            worksheet.Cell("A3").Value = $"Period: {periodLabel}";
            worksheet.Range("A3:C3").Merge();

            // Summary
            worksheet.Cell("A5").Value = "PREGLED";
            worksheet.Cell("A5").Style.Font.Bold = true;

            worksheet.Cell("A6").Value = "Ukupno termina:";
            worksheet.Cell("B6").Value = report.TotalAppointments;
            worksheet.Cell("A7").Value = "Treninzi:";
            worksheet.Cell("B7").Value = report.TrainerAppointments;
            worksheet.Cell("A8").Value = "Konsultacije:";
            worksheet.Cell("B8").Value = report.NutritionistAppointments;
            worksheet.Cell("A9").Value = "Ukupno trenera:";
            worksheet.Cell("B9").Value = report.TotalTrainers;
            worksheet.Cell("A10").Value = "Ukupno nutricionista:";
            worksheet.Cell("B10").Value = report.TotalNutritionists;

            var trainers = report.StaffRanking.Where(r => r.Type == "Trener").ToList();
            var nutritionists = report.StaffRanking.Where(r => r.Type == "Nutricionista").ToList();

            var activeTrainers = trainers.Count;
            var activeNutritionists = nutritionists.Count;
            var inactive = (report.TotalTrainers - activeTrainers) + (report.TotalNutritionists - activeNutritionists);
            worksheet.Cell("A11").Value = "Neaktivno osoblje:";
            worksheet.Cell("B11").Value = inactive;

            // Staff ranking table
            var row = 13;
            worksheet.Cell($"A{row}").Value = "RANG LISTA OSOBLJA";
            worksheet.Cell($"A{row}").Style.Font.Bold = true;

            if (report.StaffRanking.Any())
            {
                row++;
                worksheet.Cell($"A{row}").Value = "#";
                worksheet.Cell($"A{row}").Style.Font.Bold = true;
                worksheet.Cell($"B{row}").Value = "Ime i prezime";
                worksheet.Cell($"B{row}").Style.Font.Bold = true;
                worksheet.Cell($"C{row}").Value = "Tip";
                worksheet.Cell($"C{row}").Style.Font.Bold = true;
                worksheet.Cell($"D{row}").Value = "Broj termina";
                worksheet.Cell($"D{row}").Style.Font.Bold = true;

                for (var i = 0; i < report.StaffRanking.Count; i++)
                {
                    row++;
                    var item = report.StaffRanking[i];
                    worksheet.Cell($"A{row}").Value = i + 1;
                    worksheet.Cell($"B{row}").Value = item.Name;
                    worksheet.Cell($"C{row}").Value = item.Type;
                    worksheet.Cell($"D{row}").Value = item.AppointmentCount;
                }
            }

            worksheet.Columns().AdjustToContents();

            using var stream = new MemoryStream();
            workbook.SaveAs(stream);
            return stream.ToArray();
        }

        public async Task<byte[]> ExportStaffToPdfAsync()
        {
            const int days = 30;
            var periodLabel = "posljednjih " + days + " dana";
            var report = await _reportReadService.GetStaffReportAsync(days);
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
                        col.Item().Text("Izvještaj Osoblja").FontSize(16).FontColor(Colors.Grey.Darken2);
                        col.Item().PaddingTop(5).Text($"Datum: {StrongholdTimeUtils.LocalNow:dd.MM.yyyy HH:mm}  |  Period: {periodLabel}").FontSize(10).FontColor(Colors.Grey.Medium);
                        col.Item().PaddingTop(10).LineHorizontal(1).LineColor(Colors.Grey.Lighten2);
                    });

                    page.Content().PaddingVertical(20).Column(col =>
                    {
                        // Summary table
                        col.Item().Text("Pregled").Bold().FontSize(14);
                        col.Item().PaddingTop(10).Table(table =>
                        {
                            table.ColumnsDefinition(columns =>
                            {
                                columns.RelativeColumn(2);
                                columns.RelativeColumn(1);
                            });

                            table.Cell().Text("Ukupno termina:");
                            table.Cell().Text($"{report.TotalAppointments}").Bold();
                            table.Cell().Text("Treninzi:");
                            table.Cell().Text($"{report.TrainerAppointments}");
                            table.Cell().Text("Konsultacije:");
                            table.Cell().Text($"{report.NutritionistAppointments}");
                            table.Cell().Text("Ukupno trenera:");
                            table.Cell().Text($"{report.TotalTrainers}");
                            table.Cell().Text("Ukupno nutricionista:");
                            table.Cell().Text($"{report.TotalNutritionists}");
                        });

                        // Staff ranking
                        if (report.StaffRanking.Any())
                        {
                            col.Item().PaddingTop(20).Text("Rang lista osoblja").Bold().FontSize(14);
                            col.Item().PaddingTop(10).Table(table =>
                            {
                                table.ColumnsDefinition(columns =>
                                {
                                    columns.ConstantColumn(30);
                                    columns.RelativeColumn(3);
                                    columns.RelativeColumn(2);
                                    columns.RelativeColumn(1);
                                });

                                table.Header(header =>
                                {
                                    header.Cell().Text("#").Bold();
                                    header.Cell().Text("Ime i prezime").Bold();
                                    header.Cell().Text("Tip").Bold();
                                    header.Cell().Text("Termini").Bold();
                                });

                                for (var i = 0; i < report.StaffRanking.Count; i++)
                                {
                                    var item = report.StaffRanking[i];
                                    table.Cell().Text($"{i + 1}");
                                    table.Cell().Text(item.Name);
                                    table.Cell().Text(item.Type);
                                    table.Cell().Text($"{item.AppointmentCount}");
                                }
                            });
                        }
                    });

                    page.Footer().AlignCenter().Text(text =>
                    {
                        text.Span("Stronghold Gym (c) ").FontColor(Colors.Grey.Medium);
                        text.Span($"{StrongholdTimeUtils.LocalNow.Year}").FontColor(Colors.Grey.Medium);
                    });
                });
            });

            return document.GeneratePdf();
        }
    }
}
