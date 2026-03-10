using MediatR;
using Stronghold.Application.Interfaces;
using Stronghold.Domain.Enums;
using Stronghold.Domain.Exceptions;

namespace Stronghold.Application.Features.Appointments.RejectAppointment;

public class RejectAppointmentCommandHandler : IRequestHandler<RejectAppointmentCommand, AppointmentResponse>
{
    private readonly IAppointmentRepository _appointmentRepository;

    public RejectAppointmentCommandHandler(IAppointmentRepository appointmentRepository)
    {
        _appointmentRepository = appointmentRepository;
    }

    public async Task<AppointmentResponse> Handle(RejectAppointmentCommand request, CancellationToken cancellationToken)
    {
        var appointment = await _appointmentRepository.GetByIdWithDetailsAsync(request.Id)
            ?? throw new NotFoundException("Termin", request.Id);

        if (appointment.Status != AppointmentStatus.Pending)
            throw new InvalidOperationException("Samo termini sa statusom 'Pending' mogu biti odbijeni.");

        appointment.Status = AppointmentStatus.Rejected;
        _appointmentRepository.Update(appointment);
        await _appointmentRepository.SaveChangesAsync();

        return AppointmentMappings.ToResponse(appointment);
    }
}
