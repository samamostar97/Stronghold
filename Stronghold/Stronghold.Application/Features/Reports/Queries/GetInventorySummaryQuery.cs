using FluentValidation;
using MediatR;
using Stronghold.Application.Features.Reports.DTOs;
using Stronghold.Application.IServices;
using Stronghold.Application.Common.Authorization;

namespace Stronghold.Application.Features.Reports.Queries;

public class GetInventorySummaryQuery : IRequest<InventorySummaryResponse>, IAuthorizeAdminRequest
{
    public int DaysToAnalyze { get; set; } = 30;
}

public class GetInventorySummaryQueryHandler : IRequestHandler<GetInventorySummaryQuery, InventorySummaryResponse>
{
    private readonly IReportService _reportService;
    private readonly ICurrentUserService _currentUserService;

    public GetInventorySummaryQueryHandler(
        IReportService reportService,
        ICurrentUserService currentUserService)
    {
        _reportService = reportService;
        _currentUserService = currentUserService;
    }

public async Task<InventorySummaryResponse> Handle(GetInventorySummaryQuery request, CancellationToken cancellationToken)
    {
        return await _reportService.GetInventorySummaryAsync(request.DaysToAnalyze);
    }
    }

public class GetInventorySummaryQueryValidator : AbstractValidator<GetInventorySummaryQuery>
{
    public GetInventorySummaryQueryValidator()
    {
        RuleFor(x => x.DaysToAnalyze)
            .InclusiveBetween(1, 365).WithMessage("{PropertyName} mora biti u dozvoljenom opsegu.");
    }
    }