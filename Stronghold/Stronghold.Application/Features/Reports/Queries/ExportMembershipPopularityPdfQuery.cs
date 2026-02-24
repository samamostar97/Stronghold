using MediatR;
using Stronghold.Application.IServices;

namespace Stronghold.Application.Features.Reports.Queries;

public class ExportMembershipPopularityPdfQuery : IRequest<byte[]>
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
        EnsureAdminAccess();
        return await _reportService.ExportMembershipPopularityToPdfAsync();
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
