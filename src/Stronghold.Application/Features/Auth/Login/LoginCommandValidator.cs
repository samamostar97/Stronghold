using FluentValidation;

namespace Stronghold.Application.Features.Auth.Login;

public class LoginCommandValidator : AbstractValidator<LoginCommand>
{
    public LoginCommandValidator()
    {
        RuleFor(x => x.Username)
            .NotEmpty().WithMessage("Korisničko ime je obavezno.");

        RuleFor(x => x.Password)
            .NotEmpty().WithMessage("Lozinka je obavezna.");
    }
}
