using MediatR;
using Stronghold.Application.Features.Reports.DTOs;
using Stronghold.Application.IServices;
using Stronghold.Application.Common.Authorization;

namespace Stronghold.Application.Features.Reports.Queries;

public class GetBusinessReportQuery : IRequest<BusinessReportResponse>, IAuthorizeAdminRequest
{
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
        return await _reportService.GetBusinessReportAsync();
    }
    }