using FluentValidation;
using MediatR;
using Stronghold.Application.Common.Authorization;
using Stronghold.Application.Features.Reports.DTOs;
using Stronghold.Application.IServices;

namespace Stronghold.Application.Features.Reports.Queries;

public class GetDashboardAttentionQuery : IRequest<DashboardAttentionResponse>, IAuthorizeAdminRequest
{
    public int Days { get; set; } = 7;
}

public class GetDashboardAttentionQueryHandler : IRequestHandler<GetDashboardAttentionQuery, DashboardAttentionResponse>
{
    private readonly IReportReadService _reportReadService;

    public GetDashboardAttentionQueryHandler(IReportReadService reportReadService)
    {
        _reportReadService = reportReadService;
    }

    public async Task<DashboardAttentionResponse> Handle(GetDashboardAttentionQuery request, CancellationToken cancellationToken)
    {
        return await _reportReadService.GetDashboardAttentionAsync(request.Days);
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
