using FluentValidation;
using MediatR;
using Stronghold.Application.IServices;
using Stronghold.Application.Common.Authorization;

namespace Stronghold.Application.Features.Reports.Queries;

public class ExportMembershipPopularityExcelQuery : IRequest<byte[]>, IAuthorizeAdminRequest
{
    public DateTime? From { get; set; }
    public DateTime? To { get; set; }
}

public class ExportMembershipPopularityExcelQueryHandler : IRequestHandler<ExportMembershipPopularityExcelQuery, byte[]>
{
    private readonly IReportService _reportService;

    public ExportMembershipPopularityExcelQueryHandler(
        IReportService reportService)
    {
        _reportService = reportService;
    }

    public async Task<byte[]> Handle(ExportMembershipPopularityExcelQuery request, CancellationToken cancellationToken)
    {
        return await _reportService.ExportMembershipPopularityToExcelAsync(request.From, request.To);
    }
}

public class ExportMembershipPopularityExcelQueryValidator : AbstractValidator<ExportMembershipPopularityExcelQuery>
{
    public ExportMembershipPopularityExcelQueryValidator()
    {
        RuleFor(x => x.From)
            .LessThanOrEqualTo(x => x.To)
            .When(x => x.From.HasValue && x.To.HasValue)
            .WithMessage("Datum 'Od' mora biti prije datuma 'Do'.");
    }
}