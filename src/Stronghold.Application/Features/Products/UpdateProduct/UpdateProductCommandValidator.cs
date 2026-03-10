using FluentValidation;

namespace Stronghold.Application.Features.Products.UpdateProduct;

public class UpdateProductCommandValidator : AbstractValidator<UpdateProductCommand>
{
    public UpdateProductCommandValidator()
    {
        RuleFor(x => x.Id)
            .GreaterThan(0).WithMessage("ID proizvoda je obavezan.");

        RuleFor(x => x.Name)
            .NotEmpty().WithMessage("Naziv proizvoda je obavezan.")
            .MaximumLength(200).WithMessage("Naziv proizvoda ne smije biti duži od 200 karaktera.");

        RuleFor(x => x.Description)
            .MaximumLength(1000).WithMessage("Opis ne smije biti duži od 1000 karaktera.");

        RuleFor(x => x.Price)
            .GreaterThan(0).WithMessage("Cijena mora biti veća od 0.");

        RuleFor(x => x.StockQuantity)
            .GreaterThanOrEqualTo(0).WithMessage("Količina na stanju ne može biti negativna.");

        RuleFor(x => x.CategoryId)
            .GreaterThan(0).WithMessage("Kategorija je obavezna.");

        RuleFor(x => x.SupplierId)
            .GreaterThan(0).WithMessage("Dobavljač je obavezan.");
    }
}
