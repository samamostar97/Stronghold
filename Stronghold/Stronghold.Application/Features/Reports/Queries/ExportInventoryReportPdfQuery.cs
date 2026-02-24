using FluentValidation;
using MediatR;
using Stronghold.Application.IServices;

namespace Stronghold.Application.Features.Reports.Queries;

public class ExportInventoryReportPdfQuery : IRequest<byte[]>
{
    public int DaysToAnalyze { get; set; } = 30;
}

public class ExportInventoryReportPdfQueryHandler : IRequestHandler<ExportInventoryReportPdfQuery, byte[]>
{
    private readonly IReportService _reportService;
    private readonly ICurrentUserService _currentUserService;

    public ExportInventoryReportPdfQueryHandler(
        IReportService reportService,
        ICurrentUserService currentUserService)
    {
        _reportService = reportService;
        _currentUserService = currentUserService;
    }

    public async Task<byte[]> Handle(ExportInventoryReportPdfQuery request, CancellationToken cancellationToken)
    {
        EnsureAdminAccess();
        return await _reportService.ExportInventoryReportToPdfAsync(request.DaysToAnalyze);
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

public class ExportInventoryReportPdfQueryValidator : AbstractValidator<ExportInventoryReportPdfQuery>
{
    public ExportInventoryReportPdfQueryValidator()
    {
        RuleFor(x => x.DaysToAnalyze)
            .InclusiveBetween(1, 365).WithMessage("{PropertyName} mora biti u dozvoljenom opsegu.");
    }
}

