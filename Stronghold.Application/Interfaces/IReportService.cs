using Stronghold.Application.DTOs.Reports;

namespace Stronghold.Application.Interfaces;

public interface IReportService
{
    Task<DashboardResponse> GetDashboardAsync();

    // Poslovni izvjestaj za period "GGGG-MM" - "GGGG-MM"; default zadnjih 6 mjeseci.
    Task<RevenueReportResponse> GetRevenueReportAsync(string? from, string? to);

    // Izvjestaj o terminima osoblja za isti oblik perioda.
    Task<StaffReportResponse> GetStaffReportAsync(string? from, string? to);

    // PDF izvjestaj za tab (revenue/staff) - za preuzimanje i ispis.
    Task<byte[]> ExportPdfAsync(string reportKey, string? from, string? to);

    // Excel izvjestaj za tab (revenue/staff).
    Task<byte[]> ExportExcelAsync(string reportKey, string? from, string? to);
}
