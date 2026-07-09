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

        sheet.Cell(1, 1).Value = "Prihod ovaj mjesec (KM)";
        sheet.Cell(1, 2).Value = report.RevenueThisMonth;
        sheet.Cell(2, 1).Value = "Ukupno zadnjih 6 mjeseci (KM)";
        sheet.Cell(2, 2).Value = report.RevenueLast6Months;
        sheet.Cell(3, 1).Value = "Prosječna narudžba - 6 mj (KM)";
        sheet.Cell(3, 2).Value = Math.Round(report.AvgOrderValue6M, 2);
        sheet.Cell(4, 1).Value = "Stopa otkaza narudžbi - 6 mj (%)";
        sheet.Cell(4, 2).Value = Math.Round(report.OrderCancellationRate6M, 1);

        var row = 6;
        sheet.Cell(row, 1).Value = "Mjesec";
        sheet.Cell(row, 2).Value = "Članarine (KM)";
        sheet.Cell(row, 3).Value = "Prodavnica (KM)";
        sheet.Cell(row, 4).Value = "Ukupno (KM)";
        row++;
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
        sheet.Cell(row, 2).Value = "Kategorija";
        sheet.Cell(row, 3).Value = "Prodano (kom)";
        sheet.Cell(row, 4).Value = "Udio (%)";
        sheet.Cell(row, 5).Value = "Ocjena";
        sheet.Cell(row, 6).Value = "Prihod (KM)";
        row++;
        foreach (var product in report.TopProducts)
        {
            sheet.Cell(row, 1).Value = product.Name;
            sheet.Cell(row, 2).Value = product.CategoryName;
            sheet.Cell(row, 3).Value = product.QuantitySold;
            sheet.Cell(row, 4).Value = Math.Round(product.RevenueShare, 1);
            if (product.AverageRating == null)
            {
                sheet.Cell(row, 5).Value = "-";
            }
            else
            {
                sheet.Cell(row, 5).Value = Math.Round(product.AverageRating.Value, 1);
            }
            sheet.Cell(row, 6).Value = product.Revenue;
            row++;
        }

        row += 1;
        sheet.Cell(row, 1).Value = "Prihod po kategorijama (6 mjeseci)";
        row++;
        sheet.Cell(row, 1).Value = "Kategorija";
        sheet.Cell(row, 2).Value = "Prodano (kom)";
        sheet.Cell(row, 3).Value = "Prihod (KM)";
        sheet.Cell(row, 4).Value = "Udio (%)";
        row++;
        foreach (var category in report.RevenueByCategory)
        {
            sheet.Cell(row, 1).Value = category.CategoryName;
            sheet.Cell(row, 2).Value = category.QuantitySold;
            sheet.Cell(row, 3).Value = category.Revenue;
            sheet.Cell(row, 4).Value = Math.Round(category.RevenueShare, 1);
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
        sheet.Cell(1, 5).Value = "Prodano (30 dana)";
        sheet.Cell(1, 6).Value = "Doseg zaliha (dana)";
        sheet.Cell(1, 7).Value = "Cijena (KM)";
        sheet.Cell(1, 8).Value = "Vrijednost (KM)";
        sheet.Cell(1, 9).Value = "Status";
        var row = 2;
        foreach (var item in report.Items)
        {
            sheet.Cell(row, 1).Value = item.Name;
            sheet.Cell(row, 2).Value = item.CategoryName;
            sheet.Cell(row, 3).Value = item.SupplierName;
            sheet.Cell(row, 4).Value = item.StockQuantity;
            sheet.Cell(row, 5).Value = item.SoldLast30Days;
            if (item.StockCoverDays == null)
            {
                sheet.Cell(row, 6).Value = "-";
            }
            else
            {
                sheet.Cell(row, 6).Value = item.StockCoverDays.Value;
            }
            sheet.Cell(row, 7).Value = item.Price;
            sheet.Cell(row, 8).Value = item.StockValue;
            sheet.Cell(row, 9).Value = StockStatus(item.StockQuantity);
            row++;
        }
        sheet.Cell(row + 1, 7).Value = "UKUPNO:";
        sheet.Cell(row + 1, 8).Value = report.TotalValue;
        sheet.Cell(row + 2, 1).Value = "Ukupno artikala";
        sheet.Cell(row + 2, 2).Value = report.TotalItems;
        sheet.Cell(row + 3, 1).Value = "Bez zaliha";
        sheet.Cell(row + 3, 2).Value = report.OutOfStockCount;
        sheet.Cell(row + 4, 1).Value = "Niske zalihe (<10)";
        sheet.Cell(row + 4, 2).Value = report.LowStockCount;
        sheet.Cell(row + 5, 1).Value = "Bez prodaje (30 dana)";
        sheet.Cell(row + 5, 2).Value = report.NoSalesLast30Count;

        row += 7;
        sheet.Cell(row, 1).Value = "Najlošije ocijenjeni proizvodi";
        row++;
        sheet.Cell(row, 1).Value = "Proizvod";
        sheet.Cell(row, 2).Value = "Ocjena";
        sheet.Cell(row, 3).Value = "Broj recenzija";
        sheet.Cell(row, 4).Value = "Prodano (30 dana)";
        row++;
        foreach (var product in report.WorstRated)
        {
            sheet.Cell(row, 1).Value = product.Name;
            sheet.Cell(row, 2).Value = Math.Round(product.AverageRating, 1);
            sheet.Cell(row, 3).Value = product.ReviewCount;
            sheet.Cell(row, 4).Value = product.SoldLast30Days;
            row++;
        }

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
        sheet.Cell(3, 1).Value = "Novi članovi (ovaj mjesec)";
        sheet.Cell(3, 2).Value = report.NewMembersThisMonth;
        sheet.Cell(4, 1).Value = "Ukinutih članarina";
        sheet.Cell(4, 2).Value = report.RevokedCount;

        sheet.Cell(6, 1).Value = "Paket";
        sheet.Cell(6, 2).Value = "Aktivnih članarina";
        var row = 7;
        foreach (var package in report.ByPackage)
        {
            sheet.Cell(row, 1).Value = package.PackageName;
            sheet.Cell(row, 2).Value = package.ActiveCount;
            row++;
        }

        row += 1;
        sheet.Cell(row, 1).Value = "Paket";
        sheet.Cell(row, 2).Value = "Prodano (ukupno)";
        sheet.Cell(row, 3).Value = "Prodano (6 mj)";
        sheet.Cell(row, 4).Value = "Prihod (KM)";
        row++;
        foreach (var sales in report.PackageSales)
        {
            sheet.Cell(row, 1).Value = sales.PackageName;
            sheet.Cell(row, 2).Value = sales.SoldCount;
            sheet.Cell(row, 3).Value = sales.SoldLast6Months;
            sheet.Cell(row, 4).Value = sales.Revenue;
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

    private static string StockStatus(int quantity) => quantity switch
    {
        0 => "Nema na stanju",
        < 10 => "Nisko",
        _ => "OK"
    };

    private static byte[] Finalize(XLWorkbook workbook, IXLWorksheet sheet)
    {
        sheet.Row(1).Style.Font.Bold = true;
        sheet.Columns().AdjustToContents();
        using var stream = new MemoryStream();
        workbook.SaveAs(stream);
        return stream.ToArray();
    }
}
