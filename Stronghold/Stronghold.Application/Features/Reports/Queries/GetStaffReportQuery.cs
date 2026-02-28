using FluentValidation;
using MediatR;
using Stronghold.Application.Features.Reports.DTOs;
using Stronghold.Application.IServices;
using Stronghold.Application.Common.Authorization;

namespace Stronghold.Application.Features.Reports.Queries;

public class GetStaffReportQuery : IRequest<StaffReportResponse>, IAuthorizeAdminRequest
{
    public int Days { get; set; } = 30;
}

public class GetStaffReportQueryHandler : IRequestHandler<GetStaffReportQuery, StaffReportResponse>
{
    private readonly IReportReadService _reportService;

    public GetStaffReportQueryHandler(IReportReadService reportService)
    {
        _reportService = reportService;
    }

    public async Task<StaffReportResponse> Handle(GetStaffReportQuery request, CancellationToken cancellationToken)
    {
        return await _reportService.GetStaffReportAsync(request.Days);
    }
}

public class GetStaffReportQueryValidator : AbstractValidator<GetStaffReportQuery>
{
    public GetStaffReportQueryValidator()
    {
        RuleFor(x => x.Days)
            .InclusiveBetween(1, 365).WithMessage("{PropertyName} mora biti u dozvoljenom opsegu.");
    }
}
