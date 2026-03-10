using MediatR;
using Stronghold.Application.Common;

namespace Stronghold.Application.Features.Appointments.ApproveAppointment;

[AuthorizeRole("Admin")]
public class ApproveAppointmentCommand : IRequest<AppointmentResponse>
{
    public int Id { get; set; }
}
