using MediatR;
using Stronghold.Application.DTOs.Response;
using Stronghold.Application.IServices;

namespace Stronghold.Application.Features.Reports.Queries;

public class GetMembershipPopularityReportQuery : IRequest<MembershipPopularityReportResponse>
{
}

public class GetMembershipPopularityReportQueryHandler : IRequestHandler<GetMembershipPopularityReportQuery, MembershipPopularityReportResponse>
{
    private readonly IReportService _reportService;
    private readonly ICurrentUserService _currentUserService;

    public GetMembershipPopularityReportQueryHandler(
        IReportService reportService,
        ICurrentUserService currentUserService)
    {
        _reportService = reportService;
        _currentUserService = currentUserService;
    }

    public async Task<MembershipPopularityReportResponse> Handle(
        GetMembershipPopularityReportQuery request,
        CancellationToken cancellationToken)
    {
        EnsureAdminAccess();
        return await _reportService.GetMembershipPopularityReportAsync();
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
