using Stronghold.Application.DTOs.Reports;

namespace Stronghold.Application.Interfaces;

public interface IReportService
{
    Task<DashboardResponse> GetDashboardAsync();

    /// <summary>Uplate clanarina za period "GGGG-MM-DD" - "GGGG-MM-DD" (default zadnjih 30 dana), opciono za jednog clana.</summary>
    Task<MembershipsReportResponse> GetMembershipsReportAsync(string? from, string? to, int? userId);

    /// <summary>Prodaje u prodavnici za isti oblik perioda, opciono za jednog kupca.</summary>
    Task<ShopReportResponse> GetShopReportAsync(string? from, string? to, int? userId);

    /// <summary>PDF izvjestaj (memberships/shop) - za preuzimanje i ispis.</summary>
    Task<byte[]> ExportPdfAsync(string reportKey, string? from, string? to, int? userId);

    /// <summary>Excel izvjestaj (memberships/shop).</summary>
    Task<byte[]> ExportExcelAsync(string reportKey, string? from, string? to, int? userId);
}
