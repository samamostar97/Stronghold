using FluentValidation;

namespace Stronghold.Application.Features.Wishlist.AddToWishlist;

public class AddToWishlistCommandValidator : AbstractValidator<AddToWishlistCommand>
{
    public AddToWishlistCommandValidator()
    {
        RuleFor(x => x.ProductId)
            .GreaterThan(0).WithMessage("ID proizvoda je obavezan.");
    }
}
