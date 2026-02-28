using FluentValidation;
using MediatR;
using Stronghold.Application.IServices;
using Stronghold.Application.Common.Authorization;

namespace Stronghold.Application.Features.Reports.Queries;

public class ExportMembershipPopularityPdfQuery : IRequest<byte[]>, IAuthorizeAdminRequest
{
}

public class ExportMembershipPopularityPdfQueryHandler : IRequestHandler<ExportMembershipPopularityPdfQuery, byte[]>
{
    private readonly IReportExportService _reportService;

    public ExportMembershipPopularityPdfQueryHandler(
        IReportExportService reportService)
    {
        _reportService = reportService;
    }

    public async Task<byte[]> Handle(ExportMembershipPopularityPdfQuery request, CancellationToken cancellationToken)
    {
        return await _reportService.ExportMembershipPopularityToPdfAsync();
    }
}

public class ExportMembershipPopularityPdfQueryValidator : AbstractValidator<ExportMembershipPopularityPdfQuery> { }
