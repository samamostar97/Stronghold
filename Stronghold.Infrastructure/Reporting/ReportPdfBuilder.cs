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

    public static byte[] BuildMemberships(MembershipsReportResponse report)
    {
        var period = ReportExcelBuilder.PeriodLabel(report.FromDate, report.ToDate);
        return Build($"Izvještaj o članarinama ({period})", column =>
        {
            if (report.UserFullName != null)
            {
                column.Item().Text($"Član: {report.UserFullName}").SemiBold();
            }
            column.Item().PaddingTop(4).Text(
                $"Broj uplata: {report.PaymentCount}   " +
                $"Ukupan iznos: {report.TotalAmount:F2} KM")
                .SemiBold();

            if (report.Payments.Count == 0)
            {
                column.Item().PaddingTop(12).Text("Nema uplata u odabranom periodu.");
                return;
            }

            column.Item().PaddingTop(12).Table(table =>
            {
                table.ColumnsDefinition(columns =>
                {
                    columns.RelativeColumn(2);
                    columns.RelativeColumn(3);
                    columns.RelativeColumn(3);
                    columns.RelativeColumn(2);
                });
                table.Header(header =>
                {
                    header.Cell().Element(HeaderCell).Text("Datum");
                    header.Cell().Element(HeaderCell).Text("Član");
                    header.Cell().Element(HeaderCell).Text("Paket");
                    header.Cell().Element(HeaderCell).Text("Iznos (KM)");
                });
                foreach (var payment in report.Payments)
                {
                    table.Cell().Element(BodyCell).Text($"{payment.PaidAt:dd.MM.yyyy.}");
                    table.Cell().Element(BodyCell).Text(payment.UserFullName);
                    table.Cell().Element(BodyCell).Text(payment.PackageName);
                    table.Cell().Element(BodyCell).Text($"{payment.Amount:F2}");
                }
                // UKUPNO ide kao obican zavrsni red, ne u table.Footer (footer se ponavlja po stranici)
                table.Cell().Element(BodyCell).Text("UKUPNO").SemiBold();
                table.Cell().Element(BodyCell);
                table.Cell().Element(BodyCell).Text($"{report.PaymentCount} uplata").SemiBold();
                table.Cell().Element(BodyCell).Text($"{report.TotalAmount:F2}").SemiBold();
            });
        });
    }

    public static byte[] BuildShop(ShopReportResponse report)
    {
        var period = ReportExcelBuilder.PeriodLabel(report.FromDate, report.ToDate);
        return Build($"Izvještaj o prodavnici ({period})", column =>
        {
            if (report.UserFullName != null)
            {
                column.Item().Text($"Član: {report.UserFullName}").SemiBold();
            }
            column.Item().PaddingTop(4).Text(
                $"Broj narudžbi: {report.OrderCount}   " +
                $"Ukupna zarada: {report.TotalRevenue:F2} KM")
                .SemiBold();

            if (report.Orders.Count == 0)
            {
                column.Item().PaddingTop(12).Text("Nema narudžbi u odabranom periodu.");
                return;
            }

            column.Item().PaddingTop(12).Table(table =>
            {
                table.ColumnsDefinition(columns =>
                {
                    columns.RelativeColumn(2);
                    columns.RelativeColumn(3);
                    columns.RelativeColumn(2);
                    columns.RelativeColumn(2);
                    columns.RelativeColumn(2);
                });
                table.Header(header =>
                {
                    header.Cell().Element(HeaderCell).Text("Datum");
                    header.Cell().Element(HeaderCell).Text("Kupac");
                    header.Cell().Element(HeaderCell).Text("Br. artikala");
                    header.Cell().Element(HeaderCell).Text("Iznos (KM)");
                    header.Cell().Element(HeaderCell).Text("Status");
                });
                foreach (var order in report.Orders)
                {
                    table.Cell().Element(BodyCell).Text($"{order.CreatedAt:dd.MM.yyyy.}");
                    table.Cell().Element(BodyCell).Text(order.UserFullName);
                    table.Cell().Element(BodyCell).Text($"{order.ItemCount}");
                    table.Cell().Element(BodyCell).Text($"{order.TotalAmount:F2}");
                    table.Cell().Element(BodyCell).Text(order.Status);
                }
                table.Cell().Element(BodyCell).Text("UKUPNO").SemiBold();
                table.Cell().Element(BodyCell);
                table.Cell().Element(BodyCell).Text($"{report.OrderCount} narudžbi").SemiBold();
                table.Cell().Element(BodyCell).Text($"{report.TotalRevenue:F2}").SemiBold();
                table.Cell().Element(BodyCell);
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
