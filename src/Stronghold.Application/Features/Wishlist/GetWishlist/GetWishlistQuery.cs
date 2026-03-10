using MediatR;
using Stronghold.Application.Common;

namespace Stronghold.Application.Features.Wishlist.GetWishlist;

[AuthorizeRole("User")]
public class GetWishlistQuery : IRequest<List<WishlistItemResponse>>
{
}
