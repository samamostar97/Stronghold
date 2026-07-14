using Stronghold.Application.DTOs.Reports;

namespace Stronghold.Application.Interfaces;

public interface IReportService
{
    Task<DashboardResponse> GetDashboardAsync();

    // Uplate clanarina za period "GGGG-MM-DD" - "GGGG-MM-DD" (default zadnjih 30 dana), opciono za jednog clana.
    Task<MembershipsReportResponse> GetMembershipsReportAsync(string? from, string? to, int? userId);

    // Prodaje u prodavnici za isti oblik perioda, opciono za jednog kupca.
    Task<ShopReportResponse> GetShopReportAsync(string? from, string? to, int? userId);

    // PDF izvjestaj (memberships/shop) - za preuzimanje i ispis.
    Task<byte[]> ExportPdfAsync(string reportKey, string? from, string? to, int? userId);

    // Excel izvjestaj (memberships/shop).
    Task<byte[]> ExportExcelAsync(string reportKey, string? from, string? to, int? userId);
}
