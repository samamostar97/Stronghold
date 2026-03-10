using MediatR;
using Stronghold.Application.Common;

namespace Stronghold.Application.Features.Appointments.CreateAppointment;

[AuthorizeRole("User")]
public class CreateAppointmentCommand : IRequest<AppointmentResponse>
{
    public int StaffId { get; set; }
    public DateTime ScheduledAt { get; set; }
    public string? Notes { get; set; }
}
