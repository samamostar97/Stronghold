using FluentValidation;
using MediatR;
using Stronghold.Application.Features.Reports.DTOs;
using Stronghold.Application.IServices;
using Stronghold.Application.Common.Authorization;

namespace Stronghold.Application.Features.Reports.Queries;

public class GetInventoryReportQuery : IRequest<InventoryReportResponse>, IAuthorizeAdminRequest
{
    public int DaysToAnalyze { get; set; } = 30;
}

public class GetInventoryReportQueryHandler : IRequestHandler<GetInventoryReportQuery, InventoryReportResponse>
{
    private readonly IReportService _reportService;
    private readonly ICurrentUserService _currentUserService;

    public GetInventoryReportQueryHandler(
        IReportService reportService,
        ICurrentUserService currentUserService)
    {
        _reportService = reportService;
        _currentUserService = currentUserService;
    }

public async Task<InventoryReportResponse> Handle(GetInventoryReportQuery request, CancellationToken cancellationToken)
    {
        return await _reportService.GetInventoryReportAsync(request.DaysToAnalyze);
    }
    }

public class GetInventoryReportQueryValidator : AbstractValidator<GetInventoryReportQuery>
{
    public GetInventoryReportQueryValidator()
    {
        RuleFor(x => x.DaysToAnalyze)
            .InclusiveBetween(1, 365).WithMessage("{PropertyName} mora biti u dozvoljenom opsegu.");
    }
    }