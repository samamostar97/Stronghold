using MediatR;
using Stronghold.Application.Interfaces;
using Stronghold.Domain.Entities;
using Stronghold.Domain.Exceptions;

namespace Stronghold.Application.Features.Appointments.AdminCreateAppointment;

public class AdminCreateAppointmentCommandHandler : IRequestHandler<AdminCreateAppointmentCommand, AppointmentResponse>
{
    private readonly IAppointmentRepository _appointmentRepository;
    private readonly IUserRepository _userRepository;
    private readonly IStaffRepository _staffRepository;
    private readonly INotificationService _notificationService;

    public AdminCreateAppointmentCommandHandler(
        IAppointmentRepository appointmentRepository,
        IUserRepository userRepository,
        IStaffRepository staffRepository,
        INotificationService notificationService)
    {
        _appointmentRepository = appointmentRepository;
        _userRepository = userRepository;
        _staffRepository = staffRepository;
        _notificationService = notificationService;
    }

    public async Task<AppointmentResponse> Handle(AdminCreateAppointmentCommand request, CancellationToken cancellationToken)
    {
        var user = await _userRepository.GetByIdAsync(request.UserId)
            ?? throw new NotFoundException("Korisnik", request.UserId);

        var staff = await _staffRepository.GetByIdAsync(request.StaffId)
            ?? throw new NotFoundException("Osoblje", request.StaffId);

        var hour = request.ScheduledAt.Hour;
        if (hour < 8 || hour > 16 || request.ScheduledAt.Minute != 0)
            throw new InvalidOperationException("Termini su dostupni od 08:00 do 16:00, na puni sat.");

        var hasConflict = await _appointmentRepository.HasConflictAsync(request.StaffId, request.ScheduledAt);
        if (hasConflict)
            throw new ConflictException("Odabrani termin je već zauzet.");

        var appointment = new Appointment
        {
            UserId = request.UserId,
            UserFullName = $"{user.FirstName} {user.LastName}",
            StaffId = request.StaffId,
            StaffFullName = $"{staff.FirstName} {staff.LastName}",
            ScheduledAt = request.ScheduledAt,
            Notes = request.Notes
        };

        await _appointmentRepository.AddAsync(appointment);
        await _appointmentRepository.SaveChangesAsync();

        appointment.User = user;
        appointment.Staff = staff;

        await _notificationService.CreateAppointmentNotificationAsync(
            appointment.Id,
            $"{user.FirstName} {user.LastName}",
            $"{staff.FirstName} {staff.LastName}");

        return AppointmentMappings.ToResponse(appointment);
    }
}
