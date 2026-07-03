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
                $"Ukupno članarine: {report.TotalMembershipRevenue:F2} KM   " +
                $"Ukupno prodavnica: {report.TotalOrderRevenue:F2} KM   " +
                $"UKUPNO: {report.TotalMembershipRevenue + report.TotalOrderRevenue:F2} KM")
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
                    columns.RelativeColumn();
                    columns.RelativeColumn();
                });
                table.Header(header =>
                {
                    header.Cell().Element(HeaderCell).Text("Proizvod");
                    header.Cell().Element(HeaderCell).Text("Prodano (kom)");
                    header.Cell().Element(HeaderCell).Text("Prihod (KM)");
                });
                foreach (var product in report.TopProducts)
                {
                    table.Cell().Element(BodyCell).Text(product.Name);
                    table.Cell().Element(BodyCell).Text($"{product.QuantitySold}");
                    table.Cell().Element(BodyCell).Text($"{product.Revenue:F2}");
                }
            });
        });
    }

    public static byte[] BuildInventory(InventoryReportResponse report)
    {
        return Build("Izvještaj o inventaru", column =>
        {
            column.Item().Text(
                $"Ukupna vrijednost zaliha: {report.TotalValue:F2} KM   " +
                $"Artikala sa niskim zalihama: {report.LowStockCount}")
                .SemiBold();
            column.Item().PaddingTop(12).Table(table =>
            {
                table.ColumnsDefinition(columns =>
                {
                    columns.RelativeColumn(3);
                    columns.RelativeColumn(2);
                    columns.RelativeColumn(2);
                    columns.RelativeColumn();
                    columns.RelativeColumn();
                    columns.RelativeColumn();
                });
                table.Header(header =>
                {
                    header.Cell().Element(HeaderCell).Text("Proizvod");
                    header.Cell().Element(HeaderCell).Text("Kategorija");
                    header.Cell().Element(HeaderCell).Text("Dobavljač");
                    header.Cell().Element(HeaderCell).Text("Zalihe");
                    header.Cell().Element(HeaderCell).Text("Cijena");
                    header.Cell().Element(HeaderCell).Text("Vrijednost");
                });
                foreach (var item in report.Items)
                {
                    table.Cell().Element(BodyCell).Text(item.Name);
                    table.Cell().Element(BodyCell).Text(item.CategoryName);
                    table.Cell().Element(BodyCell).Text(item.SupplierName);
                    table.Cell().Element(BodyCell).Text($"{item.StockQuantity}");
                    table.Cell().Element(BodyCell).Text($"{item.Price:F2}");
                    table.Cell().Element(BodyCell).Text($"{item.StockValue:F2}");
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
                $"Ističe u narednih 7 dana: {report.ExpiringIn7Days}")
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

    private static IContainer HeaderCell(IContainer container) =>
        container.Background(Colors.Grey.Lighten3).Padding(6).DefaultTextStyle(t => t.SemiBold());

    private static IContainer BodyCell(IContainer container) =>
        container.BorderBottom(0.5f).BorderColor(Colors.Grey.Lighten2).Padding(6);
}
