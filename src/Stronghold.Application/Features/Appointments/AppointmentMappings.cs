using Stronghold.Domain.Entities;

namespace Stronghold.Application.Features.Appointments;

public static class AppointmentMappings
{
    public static AppointmentResponse ToResponse(Appointment appointment) => new()
    {
        Id = appointment.Id,
        UserId = appointment.UserId,
        UserName = !string.IsNullOrEmpty(appointment.UserFullName) ? appointment.UserFullName
            : appointment.User != null ? $"{appointment.User.FirstName} {appointment.User.LastName}" : string.Empty,
        StaffId = appointment.StaffId,
        StaffName = !string.IsNullOrEmpty(appointment.StaffFullName) ? appointment.StaffFullName
            : appointment.Staff != null ? $"{appointment.Staff.FirstName} {appointment.Staff.LastName}" : string.Empty,
        StaffType = appointment.Staff?.StaffType.ToString() ?? string.Empty,
        ScheduledAt = appointment.ScheduledAt,
        DurationMinutes = appointment.DurationMinutes,
        Status = appointment.Status.ToString(),
        Notes = appointment.Notes,
        CreatedAt = appointment.CreatedAt
    };
}
