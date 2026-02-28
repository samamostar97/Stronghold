using FluentValidation;
using MediatR;
using Stronghold.Application.Features.Reports.DTOs;
using Stronghold.Application.IServices;
using Stronghold.Application.Common.Authorization;

namespace Stronghold.Application.Features.Reports.Queries;

public class GetDashboardSalesQuery : IRequest<DashboardSalesResponse>, IAuthorizeAdminRequest { }

public class GetDashboardSalesQueryHandler : IRequestHandler<GetDashboardSalesQuery, DashboardSalesResponse>
{
    private readonly IReportReadService _reportService;

    public GetDashboardSalesQueryHandler(IReportReadService reportService)
    {
        _reportService = reportService;
    }

    public async Task<DashboardSalesResponse> Handle(GetDashboardSalesQuery request, CancellationToken cancellationToken)
    {
        return await _reportService.GetDashboardSalesAsync();
    }
}
