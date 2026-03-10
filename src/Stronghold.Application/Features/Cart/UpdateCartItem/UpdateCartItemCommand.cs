using MediatR;
using Stronghold.Application.Common;

namespace Stronghold.Application.Features.Cart.UpdateCartItem;

[AuthorizeRole("User")]
public class UpdateCartItemCommand : IRequest<CartItemResponse>
{
    public int Id { get; set; }
    public int Quantity { get; set; }
}
