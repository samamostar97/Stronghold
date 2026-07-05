using Stronghold.Application.DTOs.Reports;

namespace Stronghold.Application.Interfaces;

public interface IReportService
{
    Task<DashboardResponse> GetDashboardAsync();
    Task<RevenueReportResponse> GetRevenueReportAsync();
    Task<InventoryReportResponse> GetInventoryReportAsync();
    Task<MembershipReportResponse> GetMembershipReportAsync();

    // PDF izvjestaj za tab (revenue/inventory/memberships) - za preuzimanje i ispis.
    Task<byte[]> ExportPdfAsync(string reportKey);

    // Excel izvjestaj za tab (revenue/inventory/memberships).
    Task<byte[]> ExportExcelAsync(string reportKey);
}
