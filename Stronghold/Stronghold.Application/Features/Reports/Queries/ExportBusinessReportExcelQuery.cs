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

    public ExportBusinessReportExcelQueryHandler(
        IReportService reportService)
    {
        _reportService = reportService;
    }

public async Task<byte[]> Handle(ExportBusinessReportExcelQuery request, CancellationToken cancellationToken)
    {
        return await _reportService.ExportToExcelAsync();
    }
    }