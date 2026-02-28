using FluentValidation;
using MediatR;
using Stronghold.Application.IServices;
using Stronghold.Application.Common.Authorization;

namespace Stronghold.Application.Features.Reports.Queries;

public class ExportStaffPdfQuery : IRequest<byte[]>, IAuthorizeAdminRequest
{
}

public class ExportStaffPdfQueryHandler : IRequestHandler<ExportStaffPdfQuery, byte[]>
{
    private readonly IReportExportService _reportService;

    public ExportStaffPdfQueryHandler(IReportExportService reportService)
    {
        _reportService = reportService;
    }

    public async Task<byte[]> Handle(ExportStaffPdfQuery request, CancellationToken cancellationToken)
    {
        return await _reportService.ExportStaffToPdfAsync();
    }
}

public class ExportStaffPdfQueryValidator : AbstractValidator<ExportStaffPdfQuery> { }
