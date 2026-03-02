using FluentValidation;
using MediatR;
using Stronghold.Application.IServices;
using Stronghold.Application.Common.Authorization;

namespace Stronghold.Application.Features.Reports.Queries;

public class ExportMembershipPaymentsPdfQuery : IRequest<byte[]>, IAuthorizeAdminRequest
{
}

public class ExportMembershipPaymentsPdfQueryHandler : IRequestHandler<ExportMembershipPaymentsPdfQuery, byte[]>
{
    private readonly IReportExportService _reportService;

    public ExportMembershipPaymentsPdfQueryHandler(IReportExportService reportService)
    {
        _reportService = reportService;
    }

    public async Task<byte[]> Handle(ExportMembershipPaymentsPdfQuery request, CancellationToken cancellationToken)
    {
        return await _reportService.ExportMembershipPaymentsToPdfAsync();
    }
}

public class ExportMembershipPaymentsPdfQueryValidator : AbstractValidator<ExportMembershipPaymentsPdfQuery> { }
