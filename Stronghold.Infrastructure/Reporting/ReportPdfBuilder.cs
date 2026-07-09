using QuestPDF.Fluent;
using QuestPDF.Helpers;
using QuestPDF.Infrastructure;
using Stronghold.Application.DTOs.Reports;

namespace Stronghold.Infrastructure.Reporting;

/// <summary>PDF izvjestaji (QuestPDF, Community licenca) - dostupni za preuzimanje i ispis.</summary>
public static class ReportPdfBuilder
{
    static ReportPdfBuilder()
    {
        QuestPDF.Settings.License = LicenseType.Community;
    }

    public static byte[] BuildRevenue(RevenueReportResponse report)
    {
        return Build("Izvještaj o prihodima", column =>
        {
            column.Item().Text(
                $"Prihod ovaj mjesec: {report.RevenueThisMonth:F2} KM   " +
                $"Ukupno zadnjih 6 mjeseci: {report.RevenueLast6Months:F2} KM")
                .SemiBold();
            column.Item().PaddingTop(4).Text(
                $"Prosječna narudžba (6 mj): {report.AvgOrderValue6M:F2} KM   " +
                $"Stopa otkaza narudžbi (6 mj): {report.OrderCancellationRate6M:F1} %")
                .SemiBold();
            column.Item().PaddingTop(12).Text("Prihodi po mjesecima").FontSize(14).SemiBold();
            column.Item().Table(table =>
            {
                table.ColumnsDefinition(columns =>
                {
                    columns.RelativeColumn();
                    columns.RelativeColumn();
                    columns.RelativeColumn();
                    columns.RelativeColumn();
                });
                table.Header(header =>
                {
                    header.Cell().Element(HeaderCell).Text("Mjesec");
                    header.Cell().Element(HeaderCell).Text("Članarine (KM)");
                    header.Cell().Element(HeaderCell).Text("Prodavnica (KM)");
                    header.Cell().Element(HeaderCell).Text("Ukupno (KM)");
                });
                foreach (var month in report.MonthlyRevenue)
                {
                    table.Cell().Element(BodyCell).Text($"{month.Month:D2}/{month.Year}");
                    table.Cell().Element(BodyCell).Text($"{month.MembershipRevenue:F2}");
                    table.Cell().Element(BodyCell).Text($"{month.OrderRevenue:F2}");
                    table.Cell().Element(BodyCell)
                        .Text($"{month.MembershipRevenue + month.OrderRevenue:F2}");
                }
            });
            column.Item().PaddingTop(12).Text("Najprodavaniji proizvodi").FontSize(14).SemiBold();
            column.Item().Table(table =>
            {
                table.ColumnsDefinition(columns =>
                {
                    columns.RelativeColumn(3);
                    columns.RelativeColumn(2);
                    columns.RelativeColumn();
                    columns.RelativeColumn();
                    columns.RelativeColumn();
                    columns.RelativeColumn();
                });
                table.Header(header =>
                {
                    header.Cell().Element(HeaderCell).Text("Proizvod");
                    header.Cell().Element(HeaderCell).Text("Kategorija");
                    header.Cell().Element(HeaderCell).Text("Prodano (kom)");
                    header.Cell().Element(HeaderCell).Text("Udio (%)");
                    header.Cell().Element(HeaderCell).Text("Ocjena");
                    header.Cell().Element(HeaderCell).Text("Prihod (KM)");
                });
                foreach (var product in report.TopProducts)
                {
                    table.Cell().Element(BodyCell).Text(product.Name);
                    table.Cell().Element(BodyCell).Text(product.CategoryName);
                    table.Cell().Element(BodyCell).Text($"{product.QuantitySold}");
                    table.Cell().Element(BodyCell).Text($"{product.RevenueShare:F1}");
                    table.Cell().Element(BodyCell).Text(
                        product.AverageRating == null ? "-" : $"{product.AverageRating:F1}");
                    table.Cell().Element(BodyCell).Text($"{product.Revenue:F2}");
                }
            });
            column.Item().PaddingTop(12).Text("Prihod po kategorijama (zadnjih 6 mjeseci)")
                .FontSize(14).SemiBold();
            column.Item().Table(table =>
            {
                table.ColumnsDefinition(columns =>
                {
                    columns.RelativeColumn(3);
                    columns.RelativeColumn();
                    columns.RelativeColumn();
                    columns.RelativeColumn();
                });
                table.Header(header =>
                {
                    header.Cell().Element(HeaderCell).Text("Kategorija");
                    header.Cell().Element(HeaderCell).Text("Prodano (kom)");
                    header.Cell().Element(HeaderCell).Text("Prihod (KM)");
                    header.Cell().Element(HeaderCell).Text("Udio (%)");
                });
                foreach (var category in report.RevenueByCategory)
                {
                    table.Cell().Element(BodyCell).Text(category.CategoryName);
                    table.Cell().Element(BodyCell).Text($"{category.QuantitySold}");
                    table.Cell().Element(BodyCell).Text($"{category.Revenue:F2}");
                    table.Cell().Element(BodyCell).Text($"{category.RevenueShare:F1}");
                }
            });
        });
    }

    public static byte[] BuildInventory(InventoryReportResponse report)
    {
        return Build("Izvještaj o inventaru", column =>
        {
            column.Item().Text(
                $"Ukupno artikala: {report.TotalItems}   " +
                $"Bez zaliha: {report.OutOfStockCount}   " +
                $"Artikala sa niskim zalihama: {report.LowStockCount}   " +
                $"Ukupna vrijednost zaliha: {report.TotalValue:F2} KM")
                .SemiBold();
            // 8 kolona - uzi font i pazljivo dimenzionisane sirine da brojevi ne lome red
            column.Item().PaddingTop(12).DefaultTextStyle(t => t.FontSize(9)).Table(table =>
            {
                table.ColumnsDefinition(columns =>
                {
                    columns.RelativeColumn(2.6f);
                    columns.RelativeColumn(1.6f);
                    columns.RelativeColumn(1.6f);
                    columns.RelativeColumn(0.9f);
                    columns.RelativeColumn(1.2f);
                    columns.RelativeColumn(1f);
                    columns.RelativeColumn(1.2f);
                    columns.RelativeColumn(1.6f);
                });
                table.Header(header =>
                {
                    header.Cell().Element(HeaderCell).Text("Proizvod");
                    header.Cell().Element(HeaderCell).Text("Kategorija");
                    header.Cell().Element(HeaderCell).Text("Dobavljač");
                    header.Cell().Element(HeaderCell).Text("Zalihe");
                    header.Cell().Element(HeaderCell).Text("Prodano (30 d)");
                    header.Cell().Element(HeaderCell).Text("Cijena");
                    header.Cell().Element(HeaderCell).Text("Vrijednost");
                    header.Cell().Element(HeaderCell).Text("Status");
                });
                foreach (var item in report.Items)
                {
                    table.Cell().Element(BodyCell).Text(item.Name);
                    table.Cell().Element(BodyCell).Text(item.CategoryName);
                    table.Cell().Element(BodyCell).Text(item.SupplierName);
                    table.Cell().Element(BodyCell).Text($"{item.StockQuantity}");
                    table.Cell().Element(BodyCell).Text($"{item.SoldLast30Days}");
                    table.Cell().Element(BodyCell).Text($"{item.Price:F2}");
                    table.Cell().Element(BodyCell).Text($"{item.StockValue:F2}");
                    table.Cell().Element(BodyCell).Text(StockStatus(item.StockQuantity));
                }
            });
        });
    }

    public static byte[] BuildMemberships(MembershipReportResponse report)
    {
        return Build("Izvještaj o članarinama", column =>
        {
            column.Item().Text(
                $"Aktivnih članova: {report.ActiveCount}   " +
                $"Ističe u narednih 7 dana: {report.ExpiringIn7Days}   " +
                $"Novi članovi (ovaj mjesec): {report.NewMembersThisMonth}   " +
                $"Ukinutih članarina: {report.RevokedCount}")
                .SemiBold();
            column.Item().PaddingTop(12).Text("Aktivne članarine po paketima")
                .FontSize(14).SemiBold();
            column.Item().Table(table =>
            {
                table.ColumnsDefinition(columns =>
                {
                    columns.RelativeColumn(3);
                    columns.RelativeColumn();
                });
                table.Header(header =>
                {
                    header.Cell().Element(HeaderCell).Text("Paket");
                    header.Cell().Element(HeaderCell).Text("Aktivnih");
                });
                foreach (var package in report.ByPackage)
                {
                    table.Cell().Element(BodyCell).Text(package.PackageName);
                    table.Cell().Element(BodyCell).Text($"{package.ActiveCount}");
                }
            });
            column.Item().PaddingTop(12).Text("Prodaja po paketima")
                .FontSize(14).SemiBold();
            column.Item().Table(table =>
            {
                table.ColumnsDefinition(columns =>
                {
                    columns.RelativeColumn(3);
                    columns.RelativeColumn();
                    columns.RelativeColumn();
                    columns.RelativeColumn();
                });
                table.Header(header =>
                {
                    header.Cell().Element(HeaderCell).Text("Paket");
                    header.Cell().Element(HeaderCell).Text("Prodano (ukupno)");
                    header.Cell().Element(HeaderCell).Text("Prodano (6 mj)");
                    header.Cell().Element(HeaderCell).Text("Prihod (KM)");
                });
                foreach (var sales in report.PackageSales)
                {
                    table.Cell().Element(BodyCell).Text(sales.PackageName);
                    table.Cell().Element(BodyCell).Text($"{sales.SoldCount}");
                    table.Cell().Element(BodyCell).Text($"{sales.SoldLast6Months}");
                    table.Cell().Element(BodyCell).Text($"{sales.Revenue:F2}");
                }
            });
            column.Item().PaddingTop(12).Text("Posjećenost po sedmicama")
                .FontSize(14).SemiBold();
            column.Item().Table(table =>
            {
                table.ColumnsDefinition(columns =>
                {
                    columns.RelativeColumn();
                    columns.RelativeColumn();
                });
                table.Header(header =>
                {
                    header.Cell().Element(HeaderCell).Text("Sedmica od");
                    header.Cell().Element(HeaderCell).Text("Broj posjeta");
                });
                foreach (var week in report.WeeklyVisits)
                {
                    table.Cell().Element(BodyCell).Text($"{week.WeekStart:dd.MM.yyyy}.");
                    table.Cell().Element(BodyCell).Text($"{week.Count}");
                }
            });
        });
    }

    private static byte[] Build(string title, Action<ColumnDescriptor> content)
    {
        return Document.Create(container =>
        {
            container.Page(page =>
            {
                page.Size(PageSizes.A4);
                page.Margin(36);
                page.Header().Row(row =>
                {
                    row.RelativeItem().Column(column =>
                    {
                        column.Item().Text("Stronghold").FontSize(20).Bold();
                        column.Item().Text(title).FontSize(14);
                    });
                    row.ConstantItem(160).AlignRight()
                        .Text($"Generisano: {DateTime.Now:dd.MM.yyyy. HH:mm}")
                        .FontSize(9);
                });
                page.Content().PaddingTop(16).Column(content);
                page.Footer().AlignCenter().Text(text =>
                {
                    text.Span("Stranica ");
                    text.CurrentPageNumber();
                    text.Span(" / ");
                    text.TotalPages();
                });
            });
        }).GeneratePdf();
    }

    private static string StockStatus(int quantity) => quantity switch
    {
        0 => "Nema na stanju",
        < 10 => "Nisko",
        _ => "OK"
    };

    private static IContainer HeaderCell(IContainer container) =>
        container.Background(Colors.Grey.Lighten3).Padding(6).DefaultTextStyle(t => t.SemiBold());

    private static IContainer BodyCell(IContainer container) =>
        container.BorderBottom(0.5f).BorderColor(Colors.Grey.Lighten2).Padding(6);
}
