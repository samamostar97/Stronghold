using MediatR;
using Stronghold.Application.IServices;

namespace Stronghold.Application.Features.Reports.Queries;

public class ExportBusinessReportPdfQuery : IRequest<byte[]>
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
        EnsureAdminAccess();
        return await _reportService.ExportToPdfAsync();
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
