using FluentValidation;

namespace Stronghold.Application.Features.UserMemberships.CancelMembership;

public class CancelMembershipCommandValidator : AbstractValidator<CancelMembershipCommand>
{
    public CancelMembershipCommandValidator()
    {
        RuleFor(x => x.UserId)
            .GreaterThan(0).WithMessage("ID korisnika je obavezan.");
    }
}
