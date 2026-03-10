using FluentValidation;

namespace Stronghold.Application.Features.UserMemberships.AssignMembership;

public class AssignMembershipCommandValidator : AbstractValidator<AssignMembershipCommand>
{
    public AssignMembershipCommandValidator()
    {
        RuleFor(x => x.UserId)
            .GreaterThan(0).WithMessage("ID korisnika je obavezan.");

        RuleFor(x => x.MembershipPackageId)
            .GreaterThan(0).WithMessage("ID paketa članarine je obavezan.");
    }
}
