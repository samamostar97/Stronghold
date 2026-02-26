using FluentValidation;
using MediatR;
using Stronghold.Application.IServices;
using Stronghold.Application.Common.Authorization;

namespace Stronghold.Application.Features.Reports.Queries;

public class ExportBusinessReportExcelQuery : IRequest<byte[]>, IAuthorizeAdminRequest
{
    public DateTime? From { get; set; }
    public DateTime? To { get; set; }
}

public class ExportBusinessReportExcelQueryHandler : IRequestHandler<ExportBusinessReportExcelQuery, byte[]>
{
    private readonly IReportService _reportService;

    public ExportBusinessReportExcelQueryHandler(
        IReportService reportService)
    {
        _reportService = reportService;
    }

    public async Task<byte[]> Handle(ExportBusinessReportExcelQuery request, CancellationToken cancellationToken)
    {
        return await _reportService.ExportToExcelAsync(request.From, request.To);
    }
}

public class ExportBusinessReportExcelQueryValidator : AbstractValidator<ExportBusinessReportExcelQuery>
{
    public ExportBusinessReportExcelQueryValidator()
    {
        RuleFor(x => x.From)
            .LessThanOrEqualTo(x => x.To)
            .When(x => x.From.HasValue && x.To.HasValue)
            .WithMessage("Datum 'Od' mora biti prije datuma 'Do'.");
    }
}