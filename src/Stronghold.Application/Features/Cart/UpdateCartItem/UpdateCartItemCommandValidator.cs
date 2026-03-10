using FluentValidation;

namespace Stronghold.Application.Features.Cart.UpdateCartItem;

public class UpdateCartItemCommandValidator : AbstractValidator<UpdateCartItemCommand>
{
    public UpdateCartItemCommandValidator()
    {
        RuleFor(x => x.Id)
            .GreaterThan(0).WithMessage("ID stavke je obavezan.");

        RuleFor(x => x.Quantity)
            .GreaterThan(0).WithMessage("Količina mora biti veća od 0.");
    }
}
