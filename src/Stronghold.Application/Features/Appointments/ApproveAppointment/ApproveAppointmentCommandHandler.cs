using MediatR;
using Stronghold.Application.Interfaces;
using Stronghold.Domain.Enums;
using Stronghold.Domain.Exceptions;
using Stronghold.Messaging;
using Stronghold.Messaging.Events;

namespace Stronghold.Application.Features.Appointments.ApproveAppointment;

public class ApproveAppointmentCommandHandler : IRequestHandler<ApproveAppointmentCommand, AppointmentResponse>
{
    private readonly IAppointmentRepository _appointmentRepository;
    private readonly IMessagePublisher _messagePublisher;

    public ApproveAppointmentCommandHandler(
        IAppointmentRepository appointmentRepository,
        IMessagePublisher messagePublisher)
    {
        _appointmentRepository = appointmentRepository;
        _messagePublisher = messagePublisher;
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

        await _messagePublisher.PublishAsync(QueueNames.AppointmentApproved, new AppointmentApprovedEvent
        {
            Email = appointment.User.Email,
            FirstName = appointment.User.FirstName,
            StaffName = $"{appointment.Staff.FirstName} {appointment.Staff.LastName}",
            ScheduledAt = appointment.ScheduledAt
        });

        return AppointmentMappings.ToResponse(appointment);
    }
}
