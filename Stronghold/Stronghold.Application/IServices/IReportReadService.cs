using Stronghold.Application.Common;
using Stronghold.Application.Features.Reports.DTOs;

namespace Stronghold.Application.IServices;

public interface IReportReadService
{
    Task<BusinessReportResponse> GetBusinessReportAsync(int days = 30);
    Task<InventoryReportResponse> GetInventoryReportAsync(int daysToAnalyze = 30);
    Task<InventorySummaryResponse> GetInventorySummaryAsync(int daysToAnalyze = 30);
    Task<PagedResult<SlowMovingProductResponse>> GetSlowMovingProductsPagedAsync(SlowMovingProductQueryFilter filter);
    Task<MembershipPopularityReportResponse> GetMembershipPopularityReportAsync(int days = 90);
    Task<List<ActivityFeedItemResponse>> GetActivityFeedAsync(int count = 20);
    Task<StaffReportResponse> GetStaffReportAsync(int days = 30);
    Task<DashboardSalesResponse> GetDashboardSalesAsync();
    Task<DashboardAttentionResponse> GetDashboardAttentionAsync(int days = 7);
}
