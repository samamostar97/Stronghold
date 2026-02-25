using MediatR;
using Stronghold.Application.IServices;
using Stronghold.Application.Common.Authorization;

namespace Stronghold.Application.Features.Reports.Queries;

public class ExportBusinessReportExcelQuery : IRequest<byte[]>, IAuthorizeAdminRequest
{
}

public class ExportBusinessReportExcelQueryHandler : IRequestHandler<ExportBusinessReportExcelQuery, byte[]>
{
    private readonly IReportService _reportService;
    private readonly ICurrentUserService _currentUserService;

    public ExportBusinessReportExcelQueryHandler(
        IReportService reportService,
        ICurrentUserService currentUserService)
    {
        _reportService = reportService;
        _currentUserService = currentUserService;
    }

public async Task<byte[]> Handle(ExportBusinessReportExcelQuery request, CancellationToken cancellationToken)
    {
        return await _reportService.ExportToExcelAsync();
    }
    }