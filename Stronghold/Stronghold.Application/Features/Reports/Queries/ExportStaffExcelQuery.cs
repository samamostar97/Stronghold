using FluentValidation;
using MediatR;
using Stronghold.Application.IServices;
using Stronghold.Application.Common.Authorization;

namespace Stronghold.Application.Features.Reports.Queries;

public class ExportStaffExcelQuery : IRequest<byte[]>, IAuthorizeAdminRequest
{
}

public class ExportStaffExcelQueryHandler : IRequestHandler<ExportStaffExcelQuery, byte[]>
{
    private readonly IReportExportService _reportService;

    public ExportStaffExcelQueryHandler(IReportExportService reportService)
    {
        _reportService = reportService;
    }

    public async Task<byte[]> Handle(ExportStaffExcelQuery request, CancellationToken cancellationToken)
    {
        return await _reportService.ExportStaffToExcelAsync();
    }
}

public class ExportStaffExcelQueryValidator : AbstractValidator<ExportStaffExcelQuery> { }
