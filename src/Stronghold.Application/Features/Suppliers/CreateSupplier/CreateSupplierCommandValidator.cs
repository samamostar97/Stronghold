using FluentValidation;

namespace Stronghold.Application.Features.Suppliers.CreateSupplier;

public class CreateSupplierCommandValidator : AbstractValidator<CreateSupplierCommand>
{
    public CreateSupplierCommandValidator()
    {
        RuleFor(x => x.Name)
            .NotEmpty().WithMessage("Naziv dobavljača je obavezan.")
            .MaximumLength(200).WithMessage("Naziv dobavljača ne smije biti duži od 200 karaktera.");

        RuleFor(x => x.Email)
            .NotEmpty().WithMessage("Email je obavezan.")
            .EmailAddress().WithMessage("Email nije u ispravnom formatu.")
            .MaximumLength(200).WithMessage("Email ne smije biti duži od 200 karaktera.");

        RuleFor(x => x.Phone)
            .MaximumLength(20).WithMessage("Telefon ne smije biti duži od 20 karaktera.");

        RuleFor(x => x.Website)
            .MaximumLength(500).WithMessage("Website ne smije biti duži od 500 karaktera.");
    }
}
