using MediatR;
using Stronghold.Application.IServices;
using Stronghold.Application.Common.Authorization;

namespace Stronghold.Application.Features.Reports.Queries;

public class ExportBusinessReportPdfQuery : IRequest<byte[]>, IAuthorizeAdminRequest
{
}

public class ExportBusinessReportPdfQueryHandler : IRequestHandler<ExportBusinessReportPdfQuery, byte[]>
{
    private readonly IReportService _reportService;
    private readonly ICurrentUserService _currentUserService;

    public ExportBusinessReportPdfQueryHandler(
        IReportService reportService,
        ICurrentUserService currentUserService)
    {
        _reportService = reportService;
        _currentUserService = currentUserService;
    }

public async Task<byte[]> Handle(ExportBusinessReportPdfQuery request, CancellationToken cancellationToken)
    {
        return await _reportService.ExportToPdfAsync();
    }
    }