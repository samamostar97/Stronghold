using FluentValidation;

namespace Stronghold.Application.Features.Cart.AddToCart;

public class AddToCartCommandValidator : AbstractValidator<AddToCartCommand>
{
    public AddToCartCommandValidator()
    {
        RuleFor(x => x.ProductId)
            .GreaterThan(0).WithMessage("ID proizvoda je obavezan.");

        RuleFor(x => x.Quantity)
            .GreaterThan(0).WithMessage("Količina mora biti veća od 0.");
    }
}
