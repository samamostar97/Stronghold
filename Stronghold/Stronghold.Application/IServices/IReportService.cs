using Stronghold.Application.Common;
using Stronghold.Application.DTOs.Response;
using Stronghold.Application.Filters;

namespace Stronghold.Application.IServices
{
    public interface IReportService
    {
        Task<BusinessReportResponse> GetBusinessReportAsync();
        Task<InventoryReportResponse> GetInventoryReportAsync(int daysToAnalyze = 30);
        Task<InventorySummaryResponse> GetInventorySummaryAsync(int daysToAnalyze = 30);
        Task<PagedResult<SlowMovingProductResponse>> GetSlowMovingProductsPagedAsync(SlowMovingProductQueryFilter filter);
        Task<MembershipPopularityReportResponse> GetMembershipPopularityReportAsync();
        Task<byte[]> ExportToExcelAsync();
        Task<byte[]> ExportToPdfAsync();
        Task<byte[]> ExportInventoryReportToExcelAsync(int daysToAnalyze = 30);
        Task<byte[]> ExportInventoryReportToPdfAsync(int daysToAnalyze = 30);
        Task<byte[]> ExportMembershipPopularityToExcelAsync();
        Task<byte[]> ExportMembershipPopularityToPdfAsync();
    }
}
