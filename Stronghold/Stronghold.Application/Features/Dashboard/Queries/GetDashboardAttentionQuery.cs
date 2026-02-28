using FluentValidation;
using MediatR;
using Stronghold.Application.Common.Authorization;
using Stronghold.Application.Features.Dashboard.DTOs;
using Stronghold.Application.IServices;

namespace Stronghold.Application.Features.Dashboard.Queries;

public class GetDashboardAttentionQuery : IRequest<DashboardAttentionResponse>, IAuthorizeAdminRequest
{
    public int Days { get; set; } = 7;
}

public class GetDashboardAttentionQueryHandler : IRequestHandler<GetDashboardAttentionQuery, DashboardAttentionResponse>
{
    private readonly IDashboardReadService _dashboardService;

    public GetDashboardAttentionQueryHandler(IDashboardReadService dashboardService)
    {
        _dashboardService = dashboardService;
    }

    public async Task<DashboardAttentionResponse> Handle(GetDashboardAttentionQuery request, CancellationToken cancellationToken)
    {
        return await _dashboardService.GetAttentionAsync(request.Days);
    }
}

public class GetDashboardAttentionQueryValidator : AbstractValidator<GetDashboardAttentionQuery>
{
    public GetDashboardAttentionQueryValidator()
    {
        RuleFor(x => x.Days)
            .InclusiveBetween(1, 30).WithMessage("{PropertyName} mora biti u dozvoljenom opsegu.");
    }
}
