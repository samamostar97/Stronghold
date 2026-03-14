using MediatR;
using Microsoft.EntityFrameworkCore;
using Stronghold.Application.Interfaces;
using Stronghold.Domain.Enums;
using Stronghold.Domain.Exceptions;

namespace Stronghold.Application.Features.Products.DeleteProduct;

public class DeleteProductCommandHandler : IRequestHandler<DeleteProductCommand, Unit>
{
    private readonly IProductRepository _productRepository;
    private readonly IOrderItemRepository _orderItemRepository;
    private readonly IOrderRepository _orderRepository;
    private readonly IAuditService _auditService;
    private readonly ICurrentUserService _currentUserService;

    public DeleteProductCommandHandler(
        IProductRepository productRepository,
        IOrderItemRepository orderItemRepository,
        IOrderRepository orderRepository,
        IAuditService auditService,
        ICurrentUserService currentUserService)
    {
        _productRepository = productRepository;
        _orderItemRepository = orderItemRepository;
        _orderRepository = orderRepository;
        _auditService = auditService;
        _currentUserService = currentUserService;
    }

    public async Task<Unit> Handle(DeleteProductCommand request, CancellationToken cancellationToken)
    {
        var product = await _productRepository.GetByIdAsync(request.Id)
            ?? throw new NotFoundException("Proizvod", request.Id);

        var hasActiveOrders = await _orderItemRepository.Query()
            .AnyAsync(oi => oi.ProductId == request.Id &&
                (oi.Order.Status == OrderStatus.Pending || oi.Order.Status == OrderStatus.Confirmed),
                cancellationToken);
        if (hasActiveOrders)
            throw new ConflictException("Nije moguće obrisati proizvod koji ima aktivne narudžbe.");

        await _auditService.LogDeleteAsync(_currentUserService.UserId, "Product", product.Id, product);

        _productRepository.Remove(product);
        await _productRepository.SaveChangesAsync();

        return Unit.Value;
    }
}
