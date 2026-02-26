using FluentValidation;
using MediatR;
using Stronghold.Application.IServices;
using Stronghold.Application.Common.Authorization;

namespace Stronghold.Application.Features.Reports.Queries;

public class ExportInventoryReportExcelQuery : IRequest<byte[]>, IAuthorizeAdminRequest
{
    public int DaysToAnalyze { get; set; } = 30;
    public DateTime? From { get; set; }
    public DateTime? To { get; set; }
}

public class ExportInventoryReportExcelQueryHandler : IRequestHandler<ExportInventoryReportExcelQuery, byte[]>
{
    private readonly IReportService _reportService;

    public ExportInventoryReportExcelQueryHandler(
        IReportService reportService)
    {
        _reportService = reportService;
    }

    public async Task<byte[]> Handle(ExportInventoryReportExcelQuery request, CancellationToken cancellationToken)
    {
        return await _reportService.ExportInventoryReportToExcelAsync(request.DaysToAnalyze, request.From, request.To);
    }
}

public class ExportInventoryReportExcelQueryValidator : AbstractValidator<ExportInventoryReportExcelQuery>
{
    public ExportInventoryReportExcelQueryValidator()
    {
        RuleFor(x => x.DaysToAnalyze)
            .InclusiveBetween(1, 365).WithMessage("{PropertyName} mora biti u dozvoljenom opsegu.");

        RuleFor(x => x.From)
            .LessThanOrEqualTo(x => x.To)
            .When(x => x.From.HasValue && x.To.HasValue)
            .WithMessage("Datum 'Od' mora biti prije datuma 'Do'.");
    }
}