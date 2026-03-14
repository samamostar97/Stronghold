using FluentValidation;

namespace Stronghold.Application.Features.Users.UpdateMyProfile;

public class UpdateMyProfileCommandValidator : AbstractValidator<UpdateMyProfileCommand>
{
    public UpdateMyProfileCommandValidator()
    {
        RuleFor(x => x.FirstName)
            .NotEmpty().WithMessage("Ime je obavezno.")
            .MaximumLength(100).WithMessage("Ime ne smije biti duže od 100 karaktera.");

        RuleFor(x => x.LastName)
            .NotEmpty().WithMessage("Prezime je obavezno.")
            .MaximumLength(100).WithMessage("Prezime ne smije biti duže od 100 karaktera.");

        RuleFor(x => x.Phone)
            .MaximumLength(20).WithMessage("Broj telefona ne smije biti duži od 20 karaktera.")
            .Matches(@"^\+?[0-9\s\-]{7,20}$").WithMessage("Neispravan format broja telefona.")
            .When(x => !string.IsNullOrWhiteSpace(x.Phone));

        RuleFor(x => x.Address)
            .MaximumLength(300).WithMessage("Adresa ne smije biti duža od 300 karaktera.");
    }
}
