using ClosedXML.Excel;
using Stronghold.Application.DTOs.Reports;

namespace Stronghold.Infrastructure.Reporting;

/// <summary>Excel izvjestaji (ClosedXML).</summary>
public static class ReportExcelBuilder
{
    public static byte[] BuildRevenue(RevenueReportResponse report)
    {
        using var workbook = new XLWorkbook();
        var sheet = workbook.Worksheets.Add("Prihodi");

        sheet.Cell(1, 1).Value = "Mjesec";
        sheet.Cell(1, 2).Value = "Članarine (KM)";
        sheet.Cell(1, 3).Value = "Prodavnica (KM)";
        sheet.Cell(1, 4).Value = "Ukupno (KM)";
        var row = 2;
        foreach (var month in report.MonthlyRevenue)
        {
            sheet.Cell(row, 1).Value = $"{month.Month:D2}/{month.Year}";
            sheet.Cell(row, 2).Value = month.MembershipRevenue;
            sheet.Cell(row, 3).Value = month.OrderRevenue;
            sheet.Cell(row, 4).Value = month.MembershipRevenue + month.OrderRevenue;
            row++;
        }

        row += 1;
        sheet.Cell(row, 1).Value = "Najprodavaniji proizvodi";
        row++;
        sheet.Cell(row, 1).Value = "Proizvod";
        sheet.Cell(row, 2).Value = "Prodano (kom)";
        sheet.Cell(row, 3).Value = "Prihod (KM)";
        row++;
        foreach (var product in report.TopProducts)
        {
            sheet.Cell(row, 1).Value = product.Name;
            sheet.Cell(row, 2).Value = product.QuantitySold;
            sheet.Cell(row, 3).Value = product.Revenue;
            row++;
        }

        return Finalize(workbook, sheet);
    }

    public static byte[] BuildInventory(InventoryReportResponse report)
    {
        using var workbook = new XLWorkbook();
        var sheet = workbook.Worksheets.Add("Inventar");

        sheet.Cell(1, 1).Value = "Proizvod";
        sheet.Cell(1, 2).Value = "Kategorija";
        sheet.Cell(1, 3).Value = "Dobavljač";
        sheet.Cell(1, 4).Value = "Zalihe (kom)";
        sheet.Cell(1, 5).Value = "Cijena (KM)";
        sheet.Cell(1, 6).Value = "Vrijednost (KM)";
        var row = 2;
        foreach (var item in report.Items)
        {
            sheet.Cell(row, 1).Value = item.Name;
            sheet.Cell(row, 2).Value = item.CategoryName;
            sheet.Cell(row, 3).Value = item.SupplierName;
            sheet.Cell(row, 4).Value = item.StockQuantity;
            sheet.Cell(row, 5).Value = item.Price;
            sheet.Cell(row, 6).Value = item.StockValue;
            row++;
        }
        sheet.Cell(row + 1, 5).Value = "UKUPNO:";
        sheet.Cell(row + 1, 6).Value = report.TotalValue;

        return Finalize(workbook, sheet);
    }

    public static byte[] BuildMemberships(MembershipReportResponse report)
    {
        using var workbook = new XLWorkbook();
        var sheet = workbook.Worksheets.Add("Članarine");

        sheet.Cell(1, 1).Value = "Aktivnih članova";
        sheet.Cell(1, 2).Value = report.ActiveCount;
        sheet.Cell(2, 1).Value = "Ističe u 7 dana";
        sheet.Cell(2, 2).Value = report.ExpiringIn7Days;

        sheet.Cell(4, 1).Value = "Paket";
        sheet.Cell(4, 2).Value = "Aktivnih članarina";
        var row = 5;
        foreach (var package in report.ByPackage)
        {
            sheet.Cell(row, 1).Value = package.PackageName;
            sheet.Cell(row, 2).Value = package.ActiveCount;
            row++;
        }

        row += 1;
        sheet.Cell(row, 1).Value = "Sedmica od";
        sheet.Cell(row, 2).Value = "Broj posjeta";
        row++;
        foreach (var week in report.WeeklyVisits)
        {
            sheet.Cell(row, 1).Value = week.WeekStart.ToString("dd.MM.yyyy.");
            sheet.Cell(row, 2).Value = week.Count;
            row++;
        }

        return Finalize(workbook, sheet);
    }

    private static byte[] Finalize(XLWorkbook workbook, IXLWorksheet sheet)
    {
        sheet.Row(1).Style.Font.Bold = true;
        sheet.Columns().AdjustToContents();
        using var stream = new MemoryStream();
        workbook.SaveAs(stream);
        return stream.ToArray();
    }
}
