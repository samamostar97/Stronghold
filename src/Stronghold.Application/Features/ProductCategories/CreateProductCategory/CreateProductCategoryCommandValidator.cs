using FluentValidation;

namespace Stronghold.Application.Features.ProductCategories.CreateProductCategory;

public class CreateProductCategoryCommandValidator : AbstractValidator<CreateProductCategoryCommand>
{
    public CreateProductCategoryCommandValidator()
    {
        RuleFor(x => x.Name)
            .NotEmpty().WithMessage("Naziv kategorije je obavezan.")
            .MaximumLength(200).WithMessage("Naziv kategorije ne smije biti duži od 200 karaktera.");

        RuleFor(x => x.Description)
            .MaximumLength(500).WithMessage("Opis ne smije biti duži od 500 karaktera.");
    }
}
