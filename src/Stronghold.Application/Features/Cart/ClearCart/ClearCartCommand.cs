using MediatR;
using Stronghold.Application.Common;

namespace Stronghold.Application.Features.Cart.ClearCart;

[AuthorizeRole("User")]
public class ClearCartCommand : IRequest<Unit>
{
}
