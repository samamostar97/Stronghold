using MediatR;
using Stronghold.Application.Common;

namespace Stronghold.Application.Features.Reports.AppointmentsReport;

[AuthorizeRole("Admin")]
public class AppointmentsReportQuery : IRequest<ReportResult>
{
    public DateTime From { get; set; }
    public DateTime To { get; set; }
    public string Format { get; set; } = "pdf";
}
