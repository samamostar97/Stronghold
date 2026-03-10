using FluentValidation;

namespace Stronghold.Application.Features.ProductCategories.UpdateProductCategory;

public class UpdateProductCategoryCommandValidator : AbstractValidator<UpdateProductCategoryCommand>
{
    public UpdateProductCategoryCommandValidator()
    {
        RuleFor(x => x.Id)
            .GreaterThan(0).WithMessage("ID kategorije je obavezan.");

        RuleFor(x => x.Name)
            .NotEmpty().WithMessage("Naziv kategorije je obavezan.")
            .MaximumLength(200).WithMessage("Naziv kategorije ne smije biti duži od 200 karaktera.");

        RuleFor(x => x.Description)
            .MaximumLength(500).WithMessage("Opis ne smije biti duži od 500 karaktera.");
    }
}
