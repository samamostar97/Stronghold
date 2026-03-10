using FluentValidation;

namespace Stronghold.Application.Features.Auth.Logout;

public class LogoutCommandValidator : AbstractValidator<LogoutCommand>
{
    public LogoutCommandValidator()
    {
        RuleFor(x => x.RefreshToken)
            .NotEmpty().WithMessage("Refresh token je obavezan.");
    }
}
