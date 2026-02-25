using FluentValidation;
using MediatR;
using Stronghold.Application.Common;
using Stronghold.Application.IRepositories;
using Stronghold.Application.IServices;
using Stronghold.Application.Common.Authorization;

namespace Stronghold.Application.Features.Appointments.Commands;

public class CancelMyAppointmentCommand : IRequest<Unit>, IAuthorizeAuthenticatedRequest
{
    public int AppointmentId { get; set; }
}

public class CancelMyAppointmentCommandHandler : IRequestHandler<CancelMyAppointmentCommand, Unit>
{
    private readonly IAppointmentRepository _appointmentRepository;
    private readonly ICurrentUserService _currentUserService;

    public CancelMyAppointmentCommandHandler(
        IAppointmentRepository appointmentRepository,
        ICurrentUserService currentUserService)
    {
        _appointmentRepository = appointmentRepository;
        _currentUserService = currentUserService;
    }

public async Task<Unit> Handle(CancelMyAppointmentCommand request, CancellationToken cancellationToken)
    {
        var userId = _currentUserService.UserId!.Value;
        var appointment = await _appointmentRepository.GetByUserAndIdAsync(userId, request.AppointmentId, cancellationToken);
        if (appointment is null)
        {
            throw new KeyNotFoundException("Termin ne postoji.");
        }

        if (appointment.AppointmentDate < StrongholdTimeUtils.LocalNow)
        {
            throw new InvalidOperationException("Nemoguce otkazati zavrseni termin.");
        }

        await _appointmentRepository.DeleteAsync(appointment, cancellationToken);
        return Unit.Value;
    }
    }

public class CancelMyAppointmentCommandValidator : AbstractValidator<CancelMyAppointmentCommand>
{
    public CancelMyAppointmentCommandValidator()
    {
        RuleFor(x => x.AppointmentId).GreaterThan(0).WithMessage("{PropertyName} mora biti vece od dozvoljene vrijednosti.");
    }
    }