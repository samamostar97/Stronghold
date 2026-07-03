using Stronghold.Application.DTOs.Reports;

namespace Stronghold.Application.Interfaces;

public interface IReportService
{
    Task<DashboardResponse> GetDashboardAsync();
    Task<RevenueReportResponse> GetRevenueReportAsync();
    Task<InventoryReportResponse> GetInventoryReportAsync();
    Task<MembershipReportResponse> GetMembershipReportAsync();

    /// <summary>PDF izvjestaj za tab (revenue/inventory/memberships) - za preuzimanje i ispis.</summary>
    Task<byte[]> ExportPdfAsync(string reportKey);

    /// <summary>Excel izvjestaj za tab (revenue/inventory/memberships).</summary>
    Task<byte[]> ExportExcelAsync(string reportKey);
}
