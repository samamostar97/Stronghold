using FluentValidation;
using MediatR;
using Stronghold.Application.Common.Authorization;
using Stronghold.Application.Features.Reports.DTOs;
using Stronghold.Application.IServices;

namespace Stronghold.Application.Features.Reports.Queries;

public class GetDashboardOverviewQuery : IRequest<DashboardOverviewResponse>, IAuthorizeAdminRequest
{
    public int Days { get; set; } = 30;
}

public class GetDashboardOverviewQueryHandler : IRequestHandler<GetDashboardOverviewQuery, DashboardOverviewResponse>
{
    private readonly IReportReadService _reportReadService;

    public GetDashboardOverviewQueryHandler(IReportReadService reportReadService)
    {
        _reportReadService = reportReadService;
    }

    public async Task<DashboardOverviewResponse> Handle(GetDashboardOverviewQuery request, CancellationToken cancellationToken)
    {
        var report = await _reportReadService.GetBusinessReportAsync(request.Days);

        return new DashboardOverviewResponse
        {
            ActiveMemberships = report.ActiveMemberships,
            ExpiringThisWeekCount = report.ExpiringThisWeekCount,
            TodayCheckIns = report.TodayCheckIns,
            DailyVisits = report.DailyVisits,
        };
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
