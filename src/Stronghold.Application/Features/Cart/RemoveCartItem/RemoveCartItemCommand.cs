using MediatR;
using Stronghold.Application.Common;

namespace Stronghold.Application.Features.Cart.RemoveCartItem;

[AuthorizeRole("User")]
public class RemoveCartItemCommand : IRequest<Unit>
{
    public int Id { get; set; }
}
