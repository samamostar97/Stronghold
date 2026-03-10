using MediatR;
using Stronghold.Application.Common;

namespace Stronghold.Application.Features.Appointments.AdminCreateAppointment;

[AuthorizeRole("Admin")]
public class AdminCreateAppointmentCommand : IRequest<AppointmentResponse>
{
    public int UserId { get; set; }
    public int StaffId { get; set; }
    public DateTime ScheduledAt { get; set; }
    public string? Notes { get; set; }
}
