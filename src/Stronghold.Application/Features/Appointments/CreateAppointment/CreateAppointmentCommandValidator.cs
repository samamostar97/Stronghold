using FluentValidation;

namespace Stronghold.Application.Features.Appointments.CreateAppointment;

public class CreateAppointmentCommandValidator : AbstractValidator<CreateAppointmentCommand>
{
    public CreateAppointmentCommandValidator()
    {
        RuleFor(x => x.StaffId)
            .GreaterThan(0).WithMessage("ID osoblja je obavezan.");

        RuleFor(x => x.ScheduledAt)
            .NotEmpty().WithMessage("Datum i vrijeme termina su obavezni.");

        RuleFor(x => x.Notes)
            .MaximumLength(500).WithMessage("Bilješke ne smiju biti duže od 500 karaktera.");
    }
}
