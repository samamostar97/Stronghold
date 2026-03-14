using FluentValidation;
using Stronghold.Domain.Enums;

namespace Stronghold.Application.Features.Staff.CreateStaff;

public class CreateStaffCommandValidator : AbstractValidator<CreateStaffCommand>
{
    public CreateStaffCommandValidator()
    {
        RuleFor(x => x.FirstName)
            .NotEmpty().WithMessage("Ime je obavezno.")
            .MaximumLength(100).WithMessage("Ime ne smije biti duže od 100 karaktera.");

        RuleFor(x => x.LastName)
            .NotEmpty().WithMessage("Prezime je obavezno.")
            .MaximumLength(100).WithMessage("Prezime ne smije biti duže od 100 karaktera.");

        RuleFor(x => x.Email)
            .NotEmpty().WithMessage("Email je obavezan.")
            .EmailAddress().WithMessage("Neispravan format emaila.")
            .MaximumLength(200).WithMessage("Email ne smije biti duži od 200 karaktera.");

        RuleFor(x => x.Phone)
            .MaximumLength(20).WithMessage("Broj telefona ne smije biti duži od 20 karaktera.")
            .Matches(@"^\+?[0-9\s\-]{7,20}$").WithMessage("Neispravan format broja telefona.")
            .When(x => !string.IsNullOrWhiteSpace(x.Phone));

        RuleFor(x => x.Bio)
            .MaximumLength(1000).WithMessage("Biografija ne smije biti duža od 1000 karaktera.");

        RuleFor(x => x.StaffType)
            .NotEmpty().WithMessage("Tip osoblja je obavezan.")
            .Must(t => Enum.TryParse<StaffType>(t, true, out _))
            .WithMessage("Tip osoblja mora biti 'Trainer' ili 'Nutritionist'.");
    }
}
