using MediatR;
using Stronghold.Application.Interfaces;
using Stronghold.Domain.Enums;
using Stronghold.Domain.Exceptions;

namespace Stronghold.Application.Features.Appointments.ApproveAppointment;

public class ApproveAppointmentCommandHandler : IRequestHandler<ApproveAppointmentCommand, AppointmentResponse>
{
    private readonly IAppointmentRepository _appointmentRepository;

    public ApproveAppointmentCommandHandler(IAppointmentRepository appointmentRepository)
    {
        _appointmentRepository = appointmentRepository;
    }

    public async Task<AppointmentResponse> Handle(ApproveAppointmentCommand request, CancellationToken cancellationToken)
    {
        var appointment = await _appointmentRepository.GetByIdWithDetailsAsync(request.Id)
            ?? throw new NotFoundException("Termin", request.Id);

        if (appointment.Status != AppointmentStatus.Pending)
            throw new InvalidOperationException("Samo termini sa statusom 'Pending' mogu biti odobreni.");

        appointment.Status = AppointmentStatus.Approved;
        _appointmentRepository.Update(appointment);
        await _appointmentRepository.SaveChangesAsync();

        return AppointmentMappings.ToResponse(appointment);
    }
}
