using Stronghold.Application.Common;
using Stronghold.Application.Features.Reports.DTOs;

namespace Stronghold.Application.IServices
{
    public interface IReportService
    {
        Task<BusinessReportResponse> GetBusinessReportAsync(int days = 30);
        Task<InventoryReportResponse> GetInventoryReportAsync(int daysToAnalyze = 30);
        Task<InventorySummaryResponse> GetInventorySummaryAsync(int daysToAnalyze = 30);
        Task<PagedResult<SlowMovingProductResponse>> GetSlowMovingProductsPagedAsync(SlowMovingProductQueryFilter filter);
        Task<MembershipPopularityReportResponse> GetMembershipPopularityReportAsync(int days = 90);
        Task<byte[]> ExportToExcelAsync();
        Task<byte[]> ExportToPdfAsync();
        Task<byte[]> ExportInventoryReportToExcelAsync(int daysToAnalyze = 30);
        Task<byte[]> ExportInventoryReportToPdfAsync(int daysToAnalyze = 30);
        Task<byte[]> ExportMembershipPopularityToExcelAsync();
        Task<byte[]> ExportMembershipPopularityToPdfAsync();
        Task<List<ActivityFeedItemResponse>> GetActivityFeedAsync(int count = 20);
    }
}
