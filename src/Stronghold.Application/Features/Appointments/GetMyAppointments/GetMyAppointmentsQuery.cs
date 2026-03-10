using MediatR;
using Stronghold.Application.Common;

namespace Stronghold.Application.Features.Appointments.GetMyAppointments;

[AuthorizeRole("User")]
public class GetMyAppointmentsQuery : BaseQueryFilter, IRequest<PagedResult<AppointmentResponse>>
{
}
