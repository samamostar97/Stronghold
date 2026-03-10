using MediatR;
using Stronghold.Application.Common;

namespace Stronghold.Application.Features.Appointments.GetAppointments;

[AuthorizeRole("Admin")]
public class GetAppointmentsQuery : BaseQueryFilter, IRequest<PagedResult<AppointmentResponse>>
{
    public string? Status { get; set; }
    public int? StaffId { get; set; }
    public int? UserId { get; set; }
    public DateTime? FromDate { get; set; }
    public DateTime? ToDate { get; set; }
}
