using MediatR;
using Stronghold.Application.Features.Dashboard.DTOs;
using Stronghold.Application.IServices;
using Stronghold.Application.Common.Authorization;

namespace Stronghold.Application.Features.Dashboard.Queries;

public class GetDashboardSalesQuery : IRequest<DashboardSalesResponse>, IAuthorizeAdminRequest { }

public class GetDashboardSalesQueryHandler : IRequestHandler<GetDashboardSalesQuery, DashboardSalesResponse>
{
    private readonly IDashboardReadService _dashboardService;

    public GetDashboardSalesQueryHandler(IDashboardReadService dashboardService)
    {
        _dashboardService = dashboardService;
    }

    public async Task<DashboardSalesResponse> Handle(GetDashboardSalesQuery request, CancellationToken cancellationToken)
    {
        return await _dashboardService.GetSalesAsync();
    }
}
