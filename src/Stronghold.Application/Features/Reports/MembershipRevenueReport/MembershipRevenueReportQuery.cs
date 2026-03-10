using MediatR;
using Stronghold.Application.Common;

namespace Stronghold.Application.Features.Reports.MembershipRevenueReport;

[AuthorizeRole("Admin")]
public class MembershipRevenueReportQuery : IRequest<ReportResult>
{
    public DateTime From { get; set; }
    public DateTime To { get; set; }
    public string Format { get; set; } = "pdf";
}
