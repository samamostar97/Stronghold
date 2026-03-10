using MediatR;
using Stronghold.Application.Common;

namespace Stronghold.Application.Features.Appointments.CompleteAppointment;

[AuthorizeRole("Admin")]
public class CompleteAppointmentCommand : IRequest<AppointmentResponse>
{
    public int Id { get; set; }
}
