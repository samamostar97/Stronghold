using MediatR;
using Stronghold.Application.IServices;

namespace Stronghold.Application.Features.Reports.Queries;

public class ExportBusinessReportExcelQuery : IRequest<byte[]>
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
        EnsureAdminAccess();
        return await _reportService.ExportToExcelAsync();
    }

    private void EnsureAdminAccess()
    {
        if (!_currentUserService.IsAuthenticated || _currentUserService.UserId is null)
        {
            throw new UnauthorizedAccessException("Korisnik nije autentificiran.");
        }

        if (!_currentUserService.IsInRole("Admin"))
        {
            throw new UnauthorizedAccessException("Nemate dozvolu za ovu akciju.");
        }
    }
}
