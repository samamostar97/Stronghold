using FluentValidation;
using MediatR;
using Stronghold.Application.Features.Reports.DTOs;
using Stronghold.Application.IServices;
using Stronghold.Application.Common.Authorization;

namespace Stronghold.Application.Features.Reports.Queries;

public class GetBusinessReportQuery : IRequest<BusinessReportResponse>, IAuthorizeAdminRequest
{
    public int Days { get; set; } = 30;
}

public class GetBusinessReportQueryHandler : IRequestHandler<GetBusinessReportQuery, BusinessReportResponse>
{
    private readonly IReportService _reportService;

    public GetBusinessReportQueryHandler(
        IReportService reportService)
    {
        _reportService = reportService;
    }

    public async Task<BusinessReportResponse> Handle(GetBusinessReportQuery request, CancellationToken cancellationToken)
    {
        return await _reportService.GetBusinessReportAsync(request.Days);
    }
}

public class GetBusinessReportQueryValidator : AbstractValidator<GetBusinessReportQuery>
{
    public GetBusinessReportQueryValidator()
    {
        RuleFor(x => x.Days)
            .InclusiveBetween(1, 365).WithMessage("{PropertyName} mora biti u dozvoljenom opsegu.");
    }
}
