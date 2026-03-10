using MediatR;

namespace Stronghold.Application.Features.Orders.ConfirmOrder;

public class ConfirmOrderCommand : IRequest<OrderResponse>
{
    public int Id { get; set; }
}
