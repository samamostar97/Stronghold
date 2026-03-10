using MediatR;

namespace Stronghold.Application.Features.Orders.GetOrderById;

public class GetOrderByIdQuery : IRequest<OrderResponse>
{
    public int Id { get; set; }
}
