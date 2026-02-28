using FluentValidation;
using MediatR;
using Stronghold.Application.IServices;
using Stronghold.Application.Common.Authorization;

namespace Stronghold.Application.Features.Reports.Queries;

public class ExportVisitsExcelQuery : IRequest<byte[]>, IAuthorizeAdminRequest
{
}

public class ExportVisitsExcelQueryHandler : IRequestHandler<ExportVisitsExcelQuery, byte[]>
{
    private readonly IReportExportService _reportService;

    public ExportVisitsExcelQueryHandler(IReportExportService reportService)
    {
        _reportService = reportService;
    }

    public async Task<byte[]> Handle(ExportVisitsExcelQuery request, CancellationToken cancellationToken)
    {
        return await _reportService.ExportVisitsToExcelAsync();
    }
}

public class ExportVisitsExcelQueryValidator : AbstractValidator<ExportVisitsExcelQuery> { }
