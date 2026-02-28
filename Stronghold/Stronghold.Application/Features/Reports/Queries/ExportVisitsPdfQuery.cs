using FluentValidation;
using MediatR;
using Stronghold.Application.IServices;
using Stronghold.Application.Common.Authorization;

namespace Stronghold.Application.Features.Reports.Queries;

public class ExportVisitsPdfQuery : IRequest<byte[]>, IAuthorizeAdminRequest
{
}

public class ExportVisitsPdfQueryHandler : IRequestHandler<ExportVisitsPdfQuery, byte[]>
{
    private readonly IReportExportService _reportService;

    public ExportVisitsPdfQueryHandler(IReportExportService reportService)
    {
        _reportService = reportService;
    }

    public async Task<byte[]> Handle(ExportVisitsPdfQuery request, CancellationToken cancellationToken)
    {
        return await _reportService.ExportVisitsToPdfAsync();
    }
}

public class ExportVisitsPdfQueryValidator : AbstractValidator<ExportVisitsPdfQuery> { }
