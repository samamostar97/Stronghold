using FluentValidation;

namespace Stronghold.Application.Features.Auth.Register;

public class RegisterCommandValidator : AbstractValidator<RegisterCommand>
{
    public RegisterCommandValidator()
    {
        RuleFor(x => x.Username)
            .NotEmpty().WithMessage("Korisničko ime je obavezno.")
            .MinimumLength(3).WithMessage("Korisničko ime mora imati najmanje 3 karaktera.")
            .MaximumLength(50).WithMessage("Korisničko ime ne smije biti duže od 50 karaktera.");

        RuleFor(x => x.Email)
            .NotEmpty().WithMessage("Email je obavezan.")
            .EmailAddress().WithMessage("Neispravan format emaila.")
            .MaximumLength(200).WithMessage("Email ne smije biti duži od 200 karaktera.");

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

        RuleFor(x => x.Password)
            .NotEmpty().WithMessage("Lozinka je obavezna.")
            .MinimumLength(6).WithMessage("Lozinka mora imati najmanje 6 karaktera.");

        RuleFor(x => x.ConfirmPassword)
            .Equal(x => x.Password).WithMessage("Lozinke se ne podudaraju.");
    }
}
