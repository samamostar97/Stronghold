using MediatR;
using Stronghold.Application.Common;

namespace Stronghold.Application.Features.Wishlist.AddToWishlist;

[AuthorizeRole("User")]
public class AddToWishlistCommand : IRequest<WishlistItemResponse>
{
    public int ProductId { get; set; }
}
