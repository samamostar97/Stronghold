using FluentValidation;
using MediatR;
using Stronghold.Application.IServices;
using Stronghold.Application.Common.Authorization;

namespace Stronghold.Application.Features.Reports.Queries;

public class ExportMembershipPopularityPdfQuery : IRequest<byte[]>, IAuthorizeAdminRequest
{
    public DateTime? From { get; set; }
    public DateTime? To { get; set; }
}

public class ExportMembershipPopularityPdfQueryHandler : IRequestHandler<ExportMembershipPopularityPdfQuery, byte[]>
{
    private readonly IReportService _reportService;

    public ExportMembershipPopularityPdfQueryHandler(
        IReportService reportService)
    {
        _reportService = reportService;
    }

    public async Task<byte[]> Handle(ExportMembershipPopularityPdfQuery request, CancellationToken cancellationToken)
    {
        return await _reportService.ExportMembershipPopularityToPdfAsync(request.From, request.To);
    }
}

public class ExportMembershipPopularityPdfQueryValidator : AbstractValidator<ExportMembershipPopularityPdfQuery>
{
    public ExportMembershipPopularityPdfQueryValidator()
    {
        RuleFor(x => x.From)
            .LessThanOrEqualTo(x => x.To)
            .When(x => x.From.HasValue && x.To.HasValue)
            .WithMessage("Datum 'Od' mora biti prije datuma 'Do'.");
    }
}