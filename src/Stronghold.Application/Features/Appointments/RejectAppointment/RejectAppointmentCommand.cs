using MediatR;
using Stronghold.Application.Common;

namespace Stronghold.Application.Features.Appointments.RejectAppointment;

[AuthorizeRole("Admin")]
public class RejectAppointmentCommand : IRequest<AppointmentResponse>
{
    public int Id { get; set; }
}
