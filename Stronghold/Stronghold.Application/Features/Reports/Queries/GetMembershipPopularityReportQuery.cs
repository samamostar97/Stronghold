using MediatR;
using Stronghold.Application.Features.Reports.DTOs;
using Stronghold.Application.IServices;
using Stronghold.Application.Common.Authorization;

namespace Stronghold.Application.Features.Reports.Queries;

public class GetMembershipPopularityReportQuery : IRequest<MembershipPopularityReportResponse>, IAuthorizeAdminRequest
{
}

public class GetMembershipPopularityReportQueryHandler : IRequestHandler<GetMembershipPopularityReportQuery, MembershipPopularityReportResponse>
{
    private readonly IReportService _reportService;

    public GetMembershipPopularityReportQueryHandler(
        IReportService reportService)
    {
        _reportService = reportService;
    }

public async Task<MembershipPopularityReportResponse> Handle(
        GetMembershipPopularityReportQuery request,
        CancellationToken cancellationToken)
    {
        return await _reportService.GetMembershipPopularityReportAsync();
    }
    }