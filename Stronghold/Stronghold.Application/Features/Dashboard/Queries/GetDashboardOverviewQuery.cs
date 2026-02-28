using FluentValidation;
using MediatR;
using Stronghold.Application.Common.Authorization;
using Stronghold.Application.Features.Dashboard.DTOs;
using Stronghold.Application.IServices;

namespace Stronghold.Application.Features.Dashboard.Queries;

public class GetDashboardOverviewQuery : IRequest<DashboardOverviewResponse>, IAuthorizeAdminRequest
{
    public int Days { get; set; } = 30;
}

public class GetDashboardOverviewQueryHandler : IRequestHandler<GetDashboardOverviewQuery, DashboardOverviewResponse>
{
    private readonly IDashboardReadService _dashboardService;

    public GetDashboardOverviewQueryHandler(IDashboardReadService dashboardService)
    {
        _dashboardService = dashboardService;
    }

    public async Task<DashboardOverviewResponse> Handle(GetDashboardOverviewQuery request, CancellationToken cancellationToken)
    {
        return await _dashboardService.GetOverviewAsync(request.Days);
    }
}

public class GetDashboardOverviewQueryValidator : AbstractValidator<GetDashboardOverviewQuery>
{
    public GetDashboardOverviewQueryValidator()
    {
        RuleFor(x => x.Days)
            .InclusiveBetween(1, 365).WithMessage("{PropertyName} mora biti u dozvoljenom opsegu.");
    }
}
