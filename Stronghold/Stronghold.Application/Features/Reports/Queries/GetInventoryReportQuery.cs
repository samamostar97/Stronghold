using FluentValidation;
using MediatR;
using Stronghold.Application.DTOs.Response;
using Stronghold.Application.IServices;

namespace Stronghold.Application.Features.Reports.Queries;

public class GetInventoryReportQuery : IRequest<InventoryReportResponse>
{
    public int DaysToAnalyze { get; set; } = 30;
}

public class GetInventoryReportQueryHandler : IRequestHandler<GetInventoryReportQuery, InventoryReportResponse>
{
    private readonly IReportService _reportService;
    private readonly ICurrentUserService _currentUserService;

    public GetInventoryReportQueryHandler(
        IReportService reportService,
        ICurrentUserService currentUserService)
    {
        _reportService = reportService;
        _currentUserService = currentUserService;
    }

    public async Task<InventoryReportResponse> Handle(GetInventoryReportQuery request, CancellationToken cancellationToken)
    {
        EnsureAdminAccess();
        return await _reportService.GetInventoryReportAsync(request.DaysToAnalyze);
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

public class GetInventoryReportQueryValidator : AbstractValidator<GetInventoryReportQuery>
{
    public GetInventoryReportQueryValidator()
    {
        RuleFor(x => x.DaysToAnalyze)
            .InclusiveBetween(1, 365);
    }
}
