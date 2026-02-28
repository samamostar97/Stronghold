using FluentValidation;
using MediatR;
using Stronghold.Application.Features.Reports.DTOs;
using Stronghold.Application.IServices;
using Stronghold.Application.Common.Authorization;

namespace Stronghold.Application.Features.Reports.Queries;

public class GetMembershipPopularityReportQuery : IRequest<MembershipPopularityReportResponse>, IAuthorizeAdminRequest
{
    public int Days { get; set; } = 90;
}

public class GetMembershipPopularityReportQueryHandler : IRequestHandler<GetMembershipPopularityReportQuery, MembershipPopularityReportResponse>
{
    private readonly IReportReadService _reportService;

    public GetMembershipPopularityReportQueryHandler(
        IReportReadService reportService)
    {
        _reportService = reportService;
    }

    public async Task<MembershipPopularityReportResponse> Handle(
        GetMembershipPopularityReportQuery request,
        CancellationToken cancellationToken)
    {
        return await _reportService.GetMembershipPopularityReportAsync(request.Days);
    }
}

public class GetMembershipPopularityReportQueryValidator : AbstractValidator<GetMembershipPopularityReportQuery>
{
    public GetMembershipPopularityReportQueryValidator()
    {
        RuleFor(x => x.Days)
            .InclusiveBetween(1, 365).WithMessage("{PropertyName} mora biti u dozvoljenom opsegu.");
    }
}
