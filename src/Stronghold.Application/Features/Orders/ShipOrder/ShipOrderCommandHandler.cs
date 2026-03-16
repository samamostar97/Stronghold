using MediatR;
using Stronghold.Application.Interfaces;
using Stronghold.Domain.Enums;
using Stronghold.Domain.Exceptions;
using Stronghold.Application.Common;
using Stronghold.Messaging;

namespace Stronghold.Application.Features.Orders.ShipOrder;

public class ShipOrderCommandHandler : IRequestHandler<ShipOrderCommand, OrderResponse>
{
    private readonly IOrderRepository _orderRepository;
    private readonly IMessagePublisher _messagePublisher;

    public ShipOrderCommandHandler(
        IOrderRepository orderRepository,
        IMessagePublisher messagePublisher)
    {
        _orderRepository = orderRepository;
        _messagePublisher = messagePublisher;
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

        await _messagePublisher.PublishAsync(QueueNames.EmailNotifications, EmailTemplates.OrderShipped(order.User.Email, order.User.FirstName, order.Id));

        return OrderMappings.ToResponse(order);
    }
}
