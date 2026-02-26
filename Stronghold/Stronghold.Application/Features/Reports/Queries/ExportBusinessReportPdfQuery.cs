using FluentValidation;
using MediatR;
using Stronghold.Application.IServices;
using Stronghold.Application.Common.Authorization;

namespace Stronghold.Application.Features.Reports.Queries;

public class ExportBusinessReportPdfQuery : IRequest<byte[]>, IAuthorizeAdminRequest
{
    public DateTime? From { get; set; }
    public DateTime? To { get; set; }
}

public class ExportBusinessReportPdfQueryHandler : IRequestHandler<ExportBusinessReportPdfQuery, byte[]>
{
    private readonly IReportService _reportService;

    public ExportBusinessReportPdfQueryHandler(
        IReportService reportService)
    {
        _reportService = reportService;
    }

    public async Task<byte[]> Handle(ExportBusinessReportPdfQuery request, CancellationToken cancellationToken)
    {
        return await _reportService.ExportToPdfAsync(request.From, request.To);
    }
}

public class ExportBusinessReportPdfQueryValidator : AbstractValidator<ExportBusinessReportPdfQuery>
{
    public ExportBusinessReportPdfQueryValidator()
    {
        RuleFor(x => x.From)
            .LessThanOrEqualTo(x => x.To)
            .When(x => x.From.HasValue && x.To.HasValue)
            .WithMessage("Datum 'Od' mora biti prije datuma 'Do'.");
    }
}