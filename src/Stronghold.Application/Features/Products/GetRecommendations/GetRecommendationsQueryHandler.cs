using MediatR;
using Microsoft.EntityFrameworkCore;
using Stronghold.Application.Interfaces;
using Stronghold.Domain.Entities;
using Stronghold.Domain.Enums;

namespace Stronghold.Application.Features.Products.GetRecommendations;

public class GetRecommendationsQueryHandler : IRequestHandler<GetRecommendationsQuery, List<ProductResponse>>
{
    private readonly IOrderRepository _orderRepository;
    private readonly IProductRepository _productRepository;
    private readonly ICurrentUserService _currentUserService;

    public GetRecommendationsQueryHandler(
        IOrderRepository orderRepository,
        IProductRepository productRepository,
        ICurrentUserService currentUserService)
    {
        _orderRepository = orderRepository;
        _productRepository = productRepository;
        _currentUserService = currentUserService;
    }

    public async Task<List<ProductResponse>> Handle(GetRecommendationsQuery request, CancellationToken cancellationToken)
    {
        var userId = _currentUserService.UserId;

        var userOrders = await _orderRepository.Query()
            .Include(o => o.Items).ThenInclude(i => i.Product)
            .Where(o => o.UserId == userId && o.Status != OrderStatus.Pending)
            .ToListAsync(cancellationToken);

        if (userOrders.Any())
        {
            var purchasedProductIds = userOrders
                .SelectMany(o => o.Items)
                .Select(i => i.ProductId)
                .Distinct()
                .ToList();

            var purchasedCategoryIds = userOrders
                .SelectMany(o => o.Items)
                .Select(i => i.Product.CategoryId)
                .Distinct()
                .ToList();

            var recommendations = await _productRepository.Query()
                .Include(p => p.Category)
                .Include(p => p.Supplier)
                .Where(p => purchasedCategoryIds.Contains(p.CategoryId)
                    && !purchasedProductIds.Contains(p.Id)
                    && p.StockQuantity > 0)
                .OrderByDescending(p => p.CreatedAt)
                .Take(10)
                .ToListAsync(cancellationToken);

            if (recommendations.Any())
                return recommendations.Select(ProductMappings.ToResponse).ToList();
        }

        var topSellers = await _productRepository.Query()
            .Include(p => p.Category)
            .Include(p => p.Supplier)
            .Where(p => p.StockQuantity > 0)
            .OrderByDescending(p => _orderRepository.Query()
                .SelectMany(o => o.Items)
                .Count(oi => oi.ProductId == p.Id))
            .Take(10)
            .ToListAsync(cancellationToken);

        return topSellers.Select(ProductMappings.ToResponse).ToList();
    }
}
