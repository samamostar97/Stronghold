using FluentValidation;
using MediatR;
using Stronghold.Application.IServices;
using Stronghold.Application.Common.Authorization;

namespace Stronghold.Application.Features.Reports.Queries;

public class ExportInventoryReportExcelQuery : IRequest<byte[]>, IAuthorizeAdminRequest
{
    public int DaysToAnalyze { get; set; } = 30;
}

public class ExportInventoryReportExcelQueryHandler : IRequestHandler<ExportInventoryReportExcelQuery, byte[]>
{
    private readonly IReportService _reportService;
    private readonly ICurrentUserService _currentUserService;

    public ExportInventoryReportExcelQueryHandler(
        IReportService reportService,
        ICurrentUserService currentUserService)
    {
        _reportService = reportService;
        _currentUserService = currentUserService;
    }

public async Task<byte[]> Handle(ExportInventoryReportExcelQuery request, CancellationToken cancellationToken)
    {
        return await _reportService.ExportInventoryReportToExcelAsync(request.DaysToAnalyze);
    }
    }

public class ExportInventoryReportExcelQueryValidator : AbstractValidator<ExportInventoryReportExcelQuery>
{
    public ExportInventoryReportExcelQueryValidator()
    {
        RuleFor(x => x.DaysToAnalyze)
            .InclusiveBetween(1, 365).WithMessage("{PropertyName} mora biti u dozvoljenom opsegu.");
    }
    }