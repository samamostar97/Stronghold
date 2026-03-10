using FluentValidation;

namespace Stronghold.Application.Features.Auth.AdminLogin;

public class AdminLoginCommandValidator : AbstractValidator<AdminLoginCommand>
{
    public AdminLoginCommandValidator()
    {
        RuleFor(x => x.Username)
            .NotEmpty().WithMessage("Korisničko ime je obavezno.");

        RuleFor(x => x.Password)
            .NotEmpty().WithMessage("Lozinka je obavezna.");
    }
}
