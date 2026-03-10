using MediatR;
using Stronghold.Application.Common;

namespace Stronghold.Application.Features.Cart.GetCart;

[AuthorizeRole("User")]
public class GetCartQuery : IRequest<CartResponse>
{
}
