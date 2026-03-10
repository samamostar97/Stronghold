using MediatR;
using Stronghold.Application.Common;

namespace Stronghold.Application.Features.Cart.AddToCart;

[AuthorizeRole("User")]
public class AddToCartCommand : IRequest<CartItemResponse>
{
    public int ProductId { get; set; }
    public int Quantity { get; set; }
}
