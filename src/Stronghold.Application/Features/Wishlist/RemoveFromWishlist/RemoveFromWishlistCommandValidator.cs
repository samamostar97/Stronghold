using FluentValidation;

namespace Stronghold.Application.Features.Wishlist.RemoveFromWishlist;

public class RemoveFromWishlistCommandValidator : AbstractValidator<RemoveFromWishlistCommand>
{
    public RemoveFromWishlistCommandValidator()
    {
        RuleFor(x => x.ProductId)
            .GreaterThan(0).WithMessage("ID proizvoda je obavezan.");
    }
}
