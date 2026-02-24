using FluentValidation;
using MediatR;
using Stronghold.Application.IRepositories;
using Stronghold.Application.IServices;

namespace Stronghold.Application.Features.Appointments.Commands;

public class AdminDeleteAppointmentCommand : IRequest<Unit>
{
    public int Id { get; set; }
}

public class AdminDeleteAppointmentCommandHandler : IRequestHandler<AdminDeleteAppointmentCommand, Unit>
{
    private readonly IAppointmentRepository _appointmentRepository;
    private readonly ICurrentUserService _currentUserService;

    public AdminDeleteAppointmentCommandHandler(
        IAppointmentRepository appointmentRepository,
        ICurrentUserService currentUserService)
    {
        _appointmentRepository = appointmentRepository;
        _currentUserService = currentUserService;
    }

    public async Task<Unit> Handle(AdminDeleteAppointmentCommand request, CancellationToken cancellationToken)
    {
        EnsureAdminAccess();

        var appointment = await _appointmentRepository.GetByIdAsync(request.Id, cancellationToken);
        if (appointment is null)
        {
            throw new KeyNotFoundException("Termin ne postoji.");
        }

        await _appointmentRepository.DeleteAsync(appointment, cancellationToken);
        return Unit.Value;
    }

    private void EnsureAdminAccess()
    {
        if (!_currentUserService.IsAuthenticated || _currentUserService.UserId is null)
        {
            throw new UnauthorizedAccessException("Korisnik nije autentificiran.");
        }

        if (!_currentUserService.IsInRole("Admin"))
        {
            throw new UnauthorizedAccessException("Nemate dozvolu za ovu akciju.");
        }
    }
}

public class AdminDeleteAppointmentCommandValidator : AbstractValidator<AdminDeleteAppointmentCommand>
{
    public AdminDeleteAppointmentCommandValidator()
    {
        RuleFor(x => x.Id).GreaterThan(0).WithMessage("{PropertyName} mora biti vece od dozvoljene vrijednosti.");
    }
}

