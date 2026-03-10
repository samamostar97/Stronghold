using FluentValidation;

namespace Stronghold.Application.Features.GymVisits.CheckIn;

public class CheckInCommandValidator : AbstractValidator<CheckInCommand>
{
    public CheckInCommandValidator()
    {
        RuleFor(x => x.UserId)
            .GreaterThan(0).WithMessage("ID korisnika je obavezan.");
    }
}
