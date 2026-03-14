using MediatR;
using Stronghold.Application.Interfaces;
using Stronghold.Domain.Entities;
using Stronghold.Domain.Exceptions;

namespace Stronghold.Application.Features.Appointments.CreateAppointment;

public class CreateAppointmentCommandHandler : IRequestHandler<CreateAppointmentCommand, AppointmentResponse>
{
    private readonly IAppointmentRepository _appointmentRepository;
    private readonly IStaffRepository _staffRepository;
    private readonly IUserRepository _userRepository;
    private readonly ICurrentUserService _currentUserService;
    private readonly INotificationService _notificationService;

    public CreateAppointmentCommandHandler(
        IAppointmentRepository appointmentRepository,
        IStaffRepository staffRepository,
        IUserRepository userRepository,
        ICurrentUserService currentUserService,
        INotificationService notificationService)
    {
        _appointmentRepository = appointmentRepository;
        _staffRepository = staffRepository;
        _userRepository = userRepository;
        _currentUserService = currentUserService;
        _notificationService = notificationService;
    }

    public async Task<AppointmentResponse> Handle(CreateAppointmentCommand request, CancellationToken cancellationToken)
    {
        var staff = await _staffRepository.GetByIdAsync(request.StaffId)
            ?? throw new NotFoundException("Osoblje", request.StaffId);

        var hour = request.ScheduledAt.Hour;
        if (hour < 8 || hour > 16 || request.ScheduledAt.Minute != 0)
            throw new InvalidOperationException("Termini su dostupni od 08:00 do 16:00, na puni sat.");

        if (request.ScheduledAt.Date <= DateTime.UtcNow.Date)
            throw new InvalidOperationException("Termin se može zakazati najranije za sutra.");

        var hasConflict = await _appointmentRepository.HasConflictAsync(request.StaffId, request.ScheduledAt);
        if (hasConflict)
            throw new ConflictException("Odabrani termin je već zauzet.");

        var user = await _userRepository.GetByIdAsync(_currentUserService.UserId)
            ?? throw new NotFoundException("Korisnik", _currentUserService.UserId);

        var appointment = new Appointment
        {
            UserId = _currentUserService.UserId,
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
