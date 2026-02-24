using FluentValidation;
using MediatR;
using Stronghold.Application.IServices;

namespace Stronghold.Application.Features.Reports.Queries;

public class ExportInventoryReportExcelQuery : IRequest<byte[]>
{
    public int DaysToAnalyze { get; set; } = 30;
}

public class ExportInventoryReportExcelQueryHandler : IRequestHandler<ExportInventoryReportExcelQuery, byte[]>
{
    private readonly IReportService _reportService;
    private readonly ICurrentUserService _currentUserService;

    public ExportInventoryReportExcelQueryHandler(
        IReportService reportService,
        ICurrentUserService currentUserService)
    {
        _reportService = reportService;
        _currentUserService = currentUserService;
    }

    public async Task<byte[]> Handle(ExportInventoryReportExcelQuery request, CancellationToken cancellationToken)
    {
        EnsureAdminAccess();
        return await _reportService.ExportInventoryReportToExcelAsync(request.DaysToAnalyze);
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

public class ExportInventoryReportExcelQueryValidator : AbstractValidator<ExportInventoryReportExcelQuery>
{
    public ExportInventoryReportExcelQueryValidator()
    {
        RuleFor(x => x.DaysToAnalyze)
            .InclusiveBetween(1, 365);
    }
}
