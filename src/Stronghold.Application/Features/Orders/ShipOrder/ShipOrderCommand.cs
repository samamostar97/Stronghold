using MediatR;
using Stronghold.Application.Common;

namespace Stronghold.Application.Features.Orders.ShipOrder;

[AuthorizeRole("Admin")]
public class ShipOrderCommand : IRequest<OrderResponse>
{
    public int Id { get; set; }
}
