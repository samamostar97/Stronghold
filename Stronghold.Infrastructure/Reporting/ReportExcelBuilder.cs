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

        sheet.Cell(1, 1).Value = "Period";
        sheet.Cell(1, 2).Value = PeriodLabel(report.FromMonth, report.FromYear, report.ToMonth, report.ToYear);
        sheet.Cell(2, 1).Value = "Ukupan prihod (KM)";
        sheet.Cell(2, 2).Value = report.TotalRevenue;
        sheet.Cell(3, 1).Value = "Prihod od članarina (KM)";
        sheet.Cell(3, 2).Value = report.MembershipRevenue;
        sheet.Cell(4, 1).Value = "Prihod prodavnice (KM)";
        sheet.Cell(4, 2).Value = report.OrderRevenue;
        sheet.Cell(5, 1).Value = "Novi članovi";
        sheet.Cell(5, 2).Value = report.NewMembers;
        sheet.Cell(6, 1).Value = "Broj posjeta";
        sheet.Cell(6, 2).Value = report.VisitCount;

        var row = 8;
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
        sheet.Cell(row, 4).Value = "Prihod (KM)";
        row++;
        foreach (var product in report.TopProducts)
        {
            sheet.Cell(row, 1).Value = product.Name;
            sheet.Cell(row, 2).Value = product.CategoryName;
            sheet.Cell(row, 3).Value = product.QuantitySold;
            sheet.Cell(row, 4).Value = product.Revenue;
            row++;
        }

        row += 1;
        sheet.Cell(row, 1).Value = "Prodaja članarina po paketima";
        row++;
        sheet.Cell(row, 1).Value = "Paket";
        sheet.Cell(row, 2).Value = "Prodano";
        sheet.Cell(row, 3).Value = "Prihod (KM)";
        row++;
        foreach (var package in report.PackageSales)
        {
            sheet.Cell(row, 1).Value = package.PackageName;
            sheet.Cell(row, 2).Value = package.SoldCount;
            sheet.Cell(row, 3).Value = package.Revenue;
            row++;
        }

        return Finalize(workbook, sheet);
    }

    public static byte[] BuildStaff(StaffReportResponse report)
    {
        using var workbook = new XLWorkbook();
        var sheet = workbook.Worksheets.Add("Osoblje");

        sheet.Cell(1, 1).Value = "Period";
        sheet.Cell(1, 2).Value = PeriodLabel(report.FromMonth, report.FromYear, report.ToMonth, report.ToYear);
        sheet.Cell(2, 1).Value = "Termina u periodu";
        sheet.Cell(2, 2).Value = report.TotalAppointments;
        sheet.Cell(3, 1).Value = "Održano";
        sheet.Cell(3, 2).Value = report.CompletedCount;
        sheet.Cell(4, 1).Value = "Otkazano";
        sheet.Cell(4, 2).Value = report.CancelledCount;
        sheet.Cell(5, 1).Value = "Nadolazeći";
        sheet.Cell(5, 2).Value = report.UpcomingCount;
        sheet.Cell(6, 1).Value = "Najviše termina";
        sheet.Cell(6, 2).Value = report.BusiestStaffName == null
            ? "-"
            : $"{report.BusiestStaffName} ({report.BusiestStaffCount})";
        sheet.Cell(7, 1).Value = "Najtraženija satnica";
        sheet.Cell(7, 2).Value = report.BusiestHour == null
            ? "-"
            : $"{report.BusiestHour}:00 ({report.BusiestHourCount} termina)";

        var row = 9;
        sheet.Cell(row, 1).Value = "Osoba";
        sheet.Cell(row, 2).Value = "Tip";
        sheet.Cell(row, 3).Value = "Zakazano";
        sheet.Cell(row, 4).Value = "Održano";
        sheet.Cell(row, 5).Value = "Otkazano";
        sheet.Cell(row, 6).Value = "Nadolazeći";
        row++;
        foreach (var person in report.Staff)
        {
            sheet.Cell(row, 1).Value = person.FullName;
            sheet.Cell(row, 2).Value = StaffTypeLabel(person.StaffType);
            sheet.Cell(row, 3).Value = person.TotalCount;
            sheet.Cell(row, 4).Value = person.CompletedCount;
            sheet.Cell(row, 5).Value = person.CancelledCount;
            sheet.Cell(row, 6).Value = person.UpcomingCount;
            row++;
        }

        return Finalize(workbook, sheet);
    }

    internal static string PeriodLabel(int fromMonth, int fromYear, int toMonth, int toYear)
        => $"{fromMonth:D2}/{fromYear} - {toMonth:D2}/{toYear}";

    internal static string StaffTypeLabel(string staffType)
        => staffType == "Nutritionist" ? "Nutricionista" : "Trener";

    private static byte[] Finalize(XLWorkbook workbook, IXLWorksheet sheet)
    {
        sheet.Row(1).Style.Font.Bold = true;
        sheet.Columns().AdjustToContents();
        using var stream = new MemoryStream();
        workbook.SaveAs(stream);
        return stream.ToArray();
    }
}
