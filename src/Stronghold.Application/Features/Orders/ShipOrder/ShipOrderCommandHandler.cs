using MediatR;
using Stronghold.Application.Interfaces;
using Stronghold.Domain.Enums;
using Stronghold.Domain.Exceptions;

namespace Stronghold.Application.Features.Orders.ShipOrder;

public class ShipOrderCommandHandler : IRequestHandler<ShipOrderCommand, OrderResponse>
{
    private readonly IOrderRepository _orderRepository;

    public ShipOrderCommandHandler(IOrderRepository orderRepository)
    {
        _orderRepository = orderRepository;
    }

    public async Task<OrderResponse> Handle(ShipOrderCommand request, CancellationToken cancellationToken)
    {
        var order = await _orderRepository.GetByIdWithItemsAsync(request.Id)
            ?? throw new NotFoundException("Narudžba", request.Id);

        if (order.Status != OrderStatus.Confirmed)
            throw new InvalidOperationException("Samo potvrđene narudžbe mogu biti poslane na dostavu.");

        order.Status = OrderStatus.Shipped;
        _orderRepository.Update(order);
        await _orderRepository.SaveChangesAsync();

        return OrderMappings.ToResponse(order);
    }
}
