using FluentValidation;

namespace Stronghold.Application.Features.MembershipPackages.DeleteMembershipPackage;

public class DeleteMembershipPackageCommandValidator : AbstractValidator<DeleteMembershipPackageCommand>
{
    public DeleteMembershipPackageCommandValidator()
    {
        RuleFor(x => x.Id)
            .GreaterThan(0).WithMessage("ID paketa je obavezan.");
    }
}
