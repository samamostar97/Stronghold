using FluentValidation;

namespace Stronghold.Application.Features.Appointments.AdminCreateAppointment;

public class AdminCreateAppointmentCommandValidator : AbstractValidator<AdminCreateAppointmentCommand>
{
    public AdminCreateAppointmentCommandValidator()
    {
        RuleFor(x => x.UserId)
            .GreaterThan(0).WithMessage("ID korisnika je obavezan.");

        RuleFor(x => x.StaffId)
            .GreaterThan(0).WithMessage("ID osoblja je obavezan.");

        RuleFor(x => x.ScheduledAt)
            .NotEmpty().WithMessage("Datum i vrijeme termina su obavezni.");

        RuleFor(x => x.Notes)
            .MaximumLength(500).WithMessage("Bilješke ne smiju biti duže od 500 karaktera.");
    }
}
