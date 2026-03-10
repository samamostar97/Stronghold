using MediatR;
using Stronghold.Application.Common;

namespace Stronghold.Application.Features.Orders.CreateOrder;

[AuthorizeRole("User")]
public class CreateOrderCommand : IRequest<OrderResponse>
{
    public string? DeliveryAddress { get; set; }
}
