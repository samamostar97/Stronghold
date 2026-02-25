using FluentValidation;
using MediatR;
using Stronghold.Application.IServices;
using Stronghold.Application.Common.Authorization;

namespace Stronghold.Application.Features.Reports.Queries;

public class ExportInventoryReportPdfQuery : IRequest<byte[]>, IAuthorizeAdminRequest
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
        return await _reportService.ExportInventoryReportToPdfAsync(request.DaysToAnalyze);
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