using FluentValidation;

namespace Stronghold.Application.Features.ProductCategories.DeleteProductCategory;

public class DeleteProductCategoryCommandValidator : AbstractValidator<DeleteProductCategoryCommand>
{
    public DeleteProductCategoryCommandValidator()
    {
        RuleFor(x => x.Id)
            .GreaterThan(0).WithMessage("ID kategorije je obavezan.");
    }
}
