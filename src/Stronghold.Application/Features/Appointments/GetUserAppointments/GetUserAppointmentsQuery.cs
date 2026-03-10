using MediatR;
using Stronghold.Application.Common;

namespace Stronghold.Application.Features.Appointments.GetUserAppointments;

[AuthorizeRole("Admin")]
public class GetUserAppointmentsQuery : BaseQueryFilter, IRequest<PagedResult<AppointmentResponse>>
{
    public int UserId { get; set; }
}
