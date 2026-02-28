using Stronghold.Application.Features.Dashboard.DTOs;

namespace Stronghold.Application.IServices;

public interface IDashboardReadService
{
    Task<DashboardOverviewResponse> GetOverviewAsync(int days = 30);
    Task<DashboardSalesResponse> GetSalesAsync();
    Task<DashboardAttentionResponse> GetAttentionAsync(int days = 7);
    Task<List<ActivityFeedItemResponse>> GetActivityFeedAsync(int count = 20);
}
