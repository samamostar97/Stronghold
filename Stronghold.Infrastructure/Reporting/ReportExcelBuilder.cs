using ClosedXML.Excel;
using Stronghold.Application.DTOs.Reports;

namespace Stronghold.Infrastructure.Reporting;

/// <summary>Excel izvjestaji (ClosedXML).</summary>
public static class ReportExcelBuilder
{
    private const string DateFormat = "dd.MM.yyyy.";
    private const string MoneyFormat = "#,##0.00";

    public static byte[] BuildMemberships(MembershipsReportResponse report)
    {
        using var workbook = new XLWorkbook();
        var sheet = workbook.Worksheets.Add("Članarine");

        sheet.Cell(1, 1).Value = "Period";
        sheet.Cell(1, 2).Value = PeriodLabel(report.FromDate, report.ToDate);
        var row = 2;
        if (report.UserFullName != null)
        {
            sheet.Cell(row, 1).Value = "Član";
            sheet.Cell(row, 2).Value = report.UserFullName;
            row++;
        }
        sheet.Cell(row, 1).Value = "Broj uplata";
        sheet.Cell(row, 2).Value = report.PaymentCount;
        row++;
        sheet.Cell(row, 1).Value = "Ukupan iznos (KM)";
        sheet.Cell(row, 2).Value = report.TotalAmount;
        sheet.Cell(row, 2).Style.NumberFormat.Format = MoneyFormat;
        row += 2;

        if (report.Payments.Count == 0)
        {
            sheet.Cell(row, 1).Value = "Nema uplata u odabranom periodu.";
            return Finalize(workbook, sheet);
        }

        sheet.Cell(row, 1).Value = "Datum";
        sheet.Cell(row, 2).Value = "Član";
        sheet.Cell(row, 3).Value = "Paket";
        sheet.Cell(row, 4).Value = "Iznos (KM)";
        sheet.Row(row).Style.Font.Bold = true;
        row++;
        foreach (var payment in report.Payments)
        {
            // pravi DateTime/decimal tipovi da Excel moze sortirati i filtrirati
            sheet.Cell(row, 1).Value = payment.PaidAt;
            sheet.Cell(row, 1).Style.DateFormat.Format = DateFormat;
            sheet.Cell(row, 2).Value = payment.UserFullName;
            sheet.Cell(row, 3).Value = payment.PackageName;
            sheet.Cell(row, 4).Value = payment.Amount;
            sheet.Cell(row, 4).Style.NumberFormat.Format = MoneyFormat;
            row++;
        }
        sheet.Cell(row, 1).Value = "UKUPNO";
        sheet.Cell(row, 3).Value = $"{report.PaymentCount} uplata";
        sheet.Cell(row, 4).Value = report.TotalAmount;
        sheet.Cell(row, 4).Style.NumberFormat.Format = MoneyFormat;
        sheet.Row(row).Style.Font.Bold = true;

        return Finalize(workbook, sheet);
    }

    public static byte[] BuildShop(ShopReportResponse report)
    {
        using var workbook = new XLWorkbook();
        var sheet = workbook.Worksheets.Add("Prodavnica");

        sheet.Cell(1, 1).Value = "Period";
        sheet.Cell(1, 2).Value = PeriodLabel(report.FromDate, report.ToDate);
        var row = 2;
        if (report.UserFullName != null)
        {
            sheet.Cell(row, 1).Value = "Član";
            sheet.Cell(row, 2).Value = report.UserFullName;
            row++;
        }
        sheet.Cell(row, 1).Value = "Broj narudžbi";
        sheet.Cell(row, 2).Value = report.OrderCount;
        row++;
        sheet.Cell(row, 1).Value = "Ukupna zarada (KM)";
        sheet.Cell(row, 2).Value = report.TotalRevenue;
        sheet.Cell(row, 2).Style.NumberFormat.Format = MoneyFormat;
        row += 2;

        if (report.Orders.Count == 0)
        {
            sheet.Cell(row, 1).Value = "Nema narudžbi u odabranom periodu.";
            return Finalize(workbook, sheet);
        }

        sheet.Cell(row, 1).Value = "Datum";
        sheet.Cell(row, 2).Value = "Kupac";
        sheet.Cell(row, 3).Value = "Br. artikala";
        sheet.Cell(row, 4).Value = "Iznos (KM)";
        sheet.Cell(row, 5).Value = "Status";
        sheet.Row(row).Style.Font.Bold = true;
        row++;
        foreach (var order in report.Orders)
        {
            sheet.Cell(row, 1).Value = order.CreatedAt;
            sheet.Cell(row, 1).Style.DateFormat.Format = DateFormat;
            sheet.Cell(row, 2).Value = order.UserFullName;
            sheet.Cell(row, 3).Value = order.ItemCount;
            sheet.Cell(row, 4).Value = order.TotalAmount;
            sheet.Cell(row, 4).Style.NumberFormat.Format = MoneyFormat;
            sheet.Cell(row, 5).Value = order.Status;
            row++;
        }
        sheet.Cell(row, 1).Value = "UKUPNO";
        sheet.Cell(row, 3).Value = $"{report.OrderCount} narudžbi";
        sheet.Cell(row, 4).Value = report.TotalRevenue;
        sheet.Cell(row, 4).Style.NumberFormat.Format = MoneyFormat;
        sheet.Row(row).Style.Font.Bold = true;

        return Finalize(workbook, sheet);
    }

    internal static string PeriodLabel(DateTime fromDate, DateTime toDate)
        => $"{fromDate:dd.MM.yyyy.} - {toDate:dd.MM.yyyy.}";

    private static byte[] Finalize(XLWorkbook workbook, IXLWorksheet sheet)
    {
        sheet.Row(1).Style.Font.Bold = true;
        sheet.Columns().AdjustToContents();
        using var stream = new MemoryStream();
        workbook.SaveAs(stream);
        return stream.ToArray();
    }
}
