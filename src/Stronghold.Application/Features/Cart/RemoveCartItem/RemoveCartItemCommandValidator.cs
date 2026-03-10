using FluentValidation;

namespace Stronghold.Application.Features.Cart.RemoveCartItem;

public class RemoveCartItemCommandValidator : AbstractValidator<RemoveCartItemCommand>
{
    public RemoveCartItemCommandValidator()
    {
        RuleFor(x => x.Id)
            .GreaterThan(0).WithMessage("ID stavke je obavezan.");
    }
}
