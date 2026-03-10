using FluentValidation;

namespace Stronghold.Application.Features.MembershipPackages.CreateMembershipPackage;

public class CreateMembershipPackageCommandValidator : AbstractValidator<CreateMembershipPackageCommand>
{
    public CreateMembershipPackageCommandValidator()
    {
        RuleFor(x => x.Name)
            .NotEmpty().WithMessage("Naziv paketa je obavezan.")
            .MaximumLength(200).WithMessage("Naziv paketa ne smije biti duži od 200 karaktera.");

        RuleFor(x => x.Description)
            .MaximumLength(1000).WithMessage("Opis ne smije biti duži od 1000 karaktera.");

        RuleFor(x => x.Price)
            .GreaterThan(0).WithMessage("Cijena mora biti veća od 0.");
    }
}
