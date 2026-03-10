using MediatR;
using Stronghold.Application.Common;

namespace Stronghold.Application.Features.Reports.RevenueReport;

[AuthorizeRole("Admin")]
public class RevenueReportQuery : IRequest<ReportResult>
{
    public DateTime From { get; set; }
    public DateTime To { get; set; }
    public string Format { get; set; } = "pdf";
}
