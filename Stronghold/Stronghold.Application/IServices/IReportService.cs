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
        Task<byte[]> ExportToExcelAsync(DateTime? from = null, DateTime? to = null);
        Task<byte[]> ExportToPdfAsync(DateTime? from = null, DateTime? to = null);
        Task<byte[]> ExportInventoryReportToExcelAsync(int daysToAnalyze = 30, DateTime? from = null, DateTime? to = null);
        Task<byte[]> ExportInventoryReportToPdfAsync(int daysToAnalyze = 30, DateTime? from = null, DateTime? to = null);
        Task<byte[]> ExportMembershipPopularityToExcelAsync(DateTime? from = null, DateTime? to = null);
        Task<byte[]> ExportMembershipPopularityToPdfAsync(DateTime? from = null, DateTime? to = null);
        Task<List<ActivityFeedItemResponse>> GetActivityFeedAsync(int count = 20);
    }
}
