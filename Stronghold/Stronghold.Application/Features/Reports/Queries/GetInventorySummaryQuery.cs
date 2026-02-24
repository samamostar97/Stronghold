using FluentValidation;
using MediatR;
using Stronghold.Application.Features.Reports.DTOs;
using Stronghold.Application.IServices;

namespace Stronghold.Application.Features.Reports.Queries;

public class GetInventorySummaryQuery : IRequest<InventorySummaryResponse>
{
    public int DaysToAnalyze { get; set; } = 30;
}

public class GetInventorySummaryQueryHandler : IRequestHandler<GetInventorySummaryQuery, InventorySummaryResponse>
{
    private readonly IReportService _reportService;
    private readonly ICurrentUserService _currentUserService;

    public GetInventorySummaryQueryHandler(
        IReportService reportService,
        ICurrentUserService currentUserService)
    {
        _reportService = reportService;
        _currentUserService = currentUserService;
    }

    public async Task<InventorySummaryResponse> Handle(GetInventorySummaryQuery request, CancellationToken cancellationToken)
    {
        EnsureAdminAccess();
        return await _reportService.GetInventorySummaryAsync(request.DaysToAnalyze);
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

public class GetInventorySummaryQueryValidator : AbstractValidator<GetInventorySummaryQuery>
{
    public GetInventorySummaryQueryValidator()
    {
        RuleFor(x => x.DaysToAnalyze)
            .InclusiveBetween(1, 365);
    }
}
