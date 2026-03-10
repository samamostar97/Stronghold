using MediatR;
using Stronghold.Application.Common;

namespace Stronghold.Application.Features.Wishlist.RemoveFromWishlist;

[AuthorizeRole("User")]
public class RemoveFromWishlistCommand : IRequest<Unit>
{
    public int ProductId { get; set; }
}
