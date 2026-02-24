using MediatR;
using Stronghold.Application.Features.Reports.DTOs;
using Stronghold.Application.IServices;

namespace Stronghold.Application.Features.Reports.Queries;

public class GetBusinessReportQuery : IRequest<BusinessReportResponse>
{
}

public class GetBusinessReportQueryHandler : IRequestHandler<GetBusinessReportQuery, BusinessReportResponse>
{
    private readonly IReportService _reportService;
    private readonly ICurrentUserService _currentUserService;

    public GetBusinessReportQueryHandler(
        IReportService reportService,
        ICurrentUserService currentUserService)
    {
        _reportService = reportService;
        _currentUserService = currentUserService;
    }

    public async Task<BusinessReportResponse> Handle(GetBusinessReportQuery request, CancellationToken cancellationToken)
    {
        EnsureAdminAccess();
        return await _reportService.GetBusinessReportAsync();
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
