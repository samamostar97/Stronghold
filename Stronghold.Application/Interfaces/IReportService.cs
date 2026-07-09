using Stronghold.Application.DTOs.Reports;

namespace Stronghold.Application.Interfaces;

public interface IReportService
{
    Task<DashboardResponse> GetDashboardAsync();

    /// <summary>Poslovni izvjestaj za period "GGGG-MM" - "GGGG-MM"; default zadnjih 6 mjeseci.</summary>
    Task<RevenueReportResponse> GetRevenueReportAsync(string? from, string? to);

    /// <summary>Izvjestaj o terminima osoblja za isti oblik perioda.</summary>
    Task<StaffReportResponse> GetStaffReportAsync(string? from, string? to);

    /// <summary>PDF izvjestaj za tab (revenue/staff) - za preuzimanje i ispis.</summary>
    Task<byte[]> ExportPdfAsync(string reportKey, string? from, string? to);

    /// <summary>Excel izvjestaj za tab (revenue/staff).</summary>
    Task<byte[]> ExportExcelAsync(string reportKey, string? from, string? to);
}
