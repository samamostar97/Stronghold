using FluentValidation;
using MediatR;
using Stronghold.Application.IServices;
using Stronghold.Application.Common.Authorization;

namespace Stronghold.Application.Features.Reports.Queries;

public class ExportInventoryReportPdfQuery : IRequest<byte[]>, IAuthorizeAdminRequest
{
    public int DaysToAnalyze { get; set; } = 30;
    public DateTime? From { get; set; }
    public DateTime? To { get; set; }
}

public class ExportInventoryReportPdfQueryHandler : IRequestHandler<ExportInventoryReportPdfQuery, byte[]>
{
    private readonly IReportService _reportService;

    public ExportInventoryReportPdfQueryHandler(
        IReportService reportService)
    {
        _reportService = reportService;
    }

    public async Task<byte[]> Handle(ExportInventoryReportPdfQuery request, CancellationToken cancellationToken)
    {
        return await _reportService.ExportInventoryReportToPdfAsync(request.DaysToAnalyze, request.From, request.To);
    }
}

public class ExportInventoryReportPdfQueryValidator : AbstractValidator<ExportInventoryReportPdfQuery>
{
    public ExportInventoryReportPdfQueryValidator()
    {
        RuleFor(x => x.DaysToAnalyze)
            .InclusiveBetween(1, 365).WithMessage("{PropertyName} mora biti u dozvoljenom opsegu.");

        RuleFor(x => x.From)
            .LessThanOrEqualTo(x => x.To)
            .When(x => x.From.HasValue && x.To.HasValue)
            .WithMessage("Datum 'Od' mora biti prije datuma 'Do'.");
    }
}