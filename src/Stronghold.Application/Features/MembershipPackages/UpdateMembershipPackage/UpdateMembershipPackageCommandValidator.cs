using FluentValidation;

namespace Stronghold.Application.Features.MembershipPackages.UpdateMembershipPackage;

public class UpdateMembershipPackageCommandValidator : AbstractValidator<UpdateMembershipPackageCommand>
{
    public UpdateMembershipPackageCommandValidator()
    {
        RuleFor(x => x.Id)
            .GreaterThan(0).WithMessage("ID paketa je obavezan.");

        RuleFor(x => x.Name)
            .NotEmpty().WithMessage("Naziv paketa je obavezan.")
            .MaximumLength(200).WithMessage("Naziv paketa ne smije biti duži od 200 karaktera.");

        RuleFor(x => x.Description)
            .MaximumLength(1000).WithMessage("Opis ne smije biti duži od 1000 karaktera.");

        RuleFor(x => x.Price)
            .GreaterThan(0).WithMessage("Cijena mora biti veća od 0.");
    }
}
