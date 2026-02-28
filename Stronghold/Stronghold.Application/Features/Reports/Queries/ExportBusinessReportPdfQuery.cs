using FluentValidation;
using MediatR;
using Stronghold.Application.IServices;
using Stronghold.Application.Common.Authorization;

namespace Stronghold.Application.Features.Reports.Queries;

public class ExportBusinessReportPdfQuery : IRequest<byte[]>, IAuthorizeAdminRequest
{
}

public class ExportBusinessReportPdfQueryHandler : IRequestHandler<ExportBusinessReportPdfQuery, byte[]>
{
    private readonly IReportExportService _reportService;

    public ExportBusinessReportPdfQueryHandler(
        IReportExportService reportService)
    {
        _reportService = reportService;
    }

    public async Task<byte[]> Handle(ExportBusinessReportPdfQuery request, CancellationToken cancellationToken)
    {
        return await _reportService.ExportToPdfAsync();
    }
}

public class ExportBusinessReportPdfQueryValidator : AbstractValidator<ExportBusinessReportPdfQuery> { }
