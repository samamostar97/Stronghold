using MediatR;
using Stronghold.Application.IServices;
using Stronghold.Application.Common.Authorization;

namespace Stronghold.Application.Features.Reports.Queries;

public class ExportMembershipPopularityExcelQuery : IRequest<byte[]>, IAuthorizeAdminRequest
{
}

public class ExportMembershipPopularityExcelQueryHandler : IRequestHandler<ExportMembershipPopularityExcelQuery, byte[]>
{
    private readonly IReportService _reportService;
    private readonly ICurrentUserService _currentUserService;

    public ExportMembershipPopularityExcelQueryHandler(
        IReportService reportService,
        ICurrentUserService currentUserService)
    {
        _reportService = reportService;
        _currentUserService = currentUserService;
    }

public async Task<byte[]> Handle(ExportMembershipPopularityExcelQuery request, CancellationToken cancellationToken)
    {
        return await _reportService.ExportMembershipPopularityToExcelAsync();
    }
    }