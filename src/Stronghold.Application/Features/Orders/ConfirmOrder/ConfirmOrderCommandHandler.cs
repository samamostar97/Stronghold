using MediatR;
using Stronghold.Application.Interfaces;
using Stronghold.Domain.Enums;
using Stronghold.Domain.Exceptions;

namespace Stronghold.Application.Features.Orders.ConfirmOrder;

public class ConfirmOrderCommandHandler : IRequestHandler<ConfirmOrderCommand, OrderResponse>
{
    private readonly IOrderRepository _orderRepository;
    private readonly IProductRepository _productRepository;
    private readonly INotificationService _notificationService;

    public ConfirmOrderCommandHandler(
        IOrderRepository orderRepository,
        IProductRepository productRepository,
        INotificationService notificationService)
    {
        _orderRepository = orderRepository;
        _productRepository = productRepository;
        _notificationService = notificationService;
    }

    public async Task<OrderResponse> Handle(ConfirmOrderCommand request, CancellationToken cancellationToken)
    {
        var order = await _orderRepository.GetByIdWithItemsAsync(request.Id)
            ?? throw new NotFoundException("Narudžba", request.Id);

        if (order.Status != OrderStatus.Pending)
            throw new InvalidOperationException("Samo narudžbe sa statusom 'Pending' mogu biti potvrđene.");

        foreach (var item in order.Items)
        {
            var product = await _productRepository.GetByIdAsync(item.ProductId)
                ?? throw new NotFoundException("Proizvod", item.ProductId);

            if (product.StockQuantity < item.Quantity)
                throw new InvalidOperationException($"Proizvod '{product.Name}' nema dovoljno na stanju.");

            product.StockQuantity -= item.Quantity;
            _productRepository.Update(product);
        }

        order.Status = OrderStatus.Confirmed;
        _orderRepository.Update(order);
        await _orderRepository.SaveChangesAsync();

        await _notificationService.CreateOrderNotificationAsync(order.Id);

        return OrderMappings.ToResponse(order);
    }
}
