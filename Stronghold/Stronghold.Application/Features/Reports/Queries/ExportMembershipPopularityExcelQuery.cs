using FluentValidation;
using MediatR;
using Stronghold.Application.IServices;
using Stronghold.Application.Common.Authorization;

namespace Stronghold.Application.Features.Reports.Queries;

public class ExportMembershipPopularityExcelQuery : IRequest<byte[]>, IAuthorizeAdminRequest
{
}

public class ExportMembershipPopularityExcelQueryHandler : IRequestHandler<ExportMembershipPopularityExcelQuery, byte[]>
{
    private readonly IReportExportService _reportService;

    public ExportMembershipPopularityExcelQueryHandler(
        IReportExportService reportService)
    {
        _reportService = reportService;
    }

    public async Task<byte[]> Handle(ExportMembershipPopularityExcelQuery request, CancellationToken cancellationToken)
    {
        return await _reportService.ExportMembershipPopularityToExcelAsync();
    }
}

public class ExportMembershipPopularityExcelQueryValidator : AbstractValidator<ExportMembershipPopularityExcelQuery> { }
