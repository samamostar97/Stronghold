using FluentValidation;
using MediatR;
using Stronghold.Application.IServices;
using Stronghold.Application.Common.Authorization;

namespace Stronghold.Application.Features.Reports.Queries;

public class ExportMembershipPaymentsExcelQuery : IRequest<byte[]>, IAuthorizeAdminRequest
{
}

public class ExportMembershipPaymentsExcelQueryHandler : IRequestHandler<ExportMembershipPaymentsExcelQuery, byte[]>
{
    private readonly IReportExportService _reportService;

    public ExportMembershipPaymentsExcelQueryHandler(IReportExportService reportService)
    {
        _reportService = reportService;
    }

    public async Task<byte[]> Handle(ExportMembershipPaymentsExcelQuery request, CancellationToken cancellationToken)
    {
        return await _reportService.ExportMembershipPaymentsToExcelAsync();
    }
}

public class ExportMembershipPaymentsExcelQueryValidator : AbstractValidator<ExportMembershipPaymentsExcelQuery> { }
