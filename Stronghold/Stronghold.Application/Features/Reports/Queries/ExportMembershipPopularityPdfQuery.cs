using MediatR;
using Stronghold.Application.IServices;
using Stronghold.Application.Common.Authorization;

namespace Stronghold.Application.Features.Reports.Queries;

public class ExportMembershipPopularityPdfQuery : IRequest<byte[]>, IAuthorizeAdminRequest
{
}

public class ExportMembershipPopularityPdfQueryHandler : IRequestHandler<ExportMembershipPopularityPdfQuery, byte[]>
{
    private readonly IReportService _reportService;
    private readonly ICurrentUserService _currentUserService;

    public ExportMembershipPopularityPdfQueryHandler(
        IReportService reportService,
        ICurrentUserService currentUserService)
    {
        _reportService = reportService;
        _currentUserService = currentUserService;
    }

public async Task<byte[]> Handle(ExportMembershipPopularityPdfQuery request, CancellationToken cancellationToken)
    {
        return await _reportService.ExportMembershipPopularityToPdfAsync();
    }
    }