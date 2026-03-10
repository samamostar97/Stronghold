using MediatR;
using Stronghold.Application.Common;

namespace Stronghold.Application.Features.Appointments.GetStaffAppointments;

[AuthorizeRole("Admin")]
public class GetStaffAppointmentsQuery : BaseQueryFilter, IRequest<PagedResult<AppointmentResponse>>
{
    public int StaffId { get; set; }
}
