using MediatR;
using Microsoft.EntityFrameworkCore;
using Stronghold.Application.Interfaces;
using Stronghold.Domain.Enums;

namespace Stronghold.Application.Features.Products.GetRecommendations;

public class GetRecommendationsQueryHandler : IRequestHandler<GetRecommendationsQuery, List<ProductResponse>>
{
    private readonly IOrderRepository _orderRepository;
    private readonly IOrderItemRepository _orderItemRepository;
    private readonly IProductRepository _productRepository;
    private readonly ICurrentUserService _currentUserService;

    public GetRecommendationsQueryHandler(
        IOrderRepository orderRepository,
        IOrderItemRepository orderItemRepository,
        IProductRepository productRepository,
        ICurrentUserService currentUserService)
    {
        _orderRepository = orderRepository;
        _orderItemRepository = orderItemRepository;
        _productRepository = productRepository;
        _currentUserService = currentUserService;
    }

    public async Task<List<ProductResponse>> Handle(GetRecommendationsQuery request, CancellationToken cancellationToken)
    {
        var userId = _currentUserService.UserId;

        var userOrders = await _orderRepository.QueryAll()
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

            var recommendations = await _productRepository.QueryAll()
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

        var topSellerIds = await _orderItemRepository.Query()
            .GroupBy(oi => oi.ProductId)
            .OrderByDescending(g => g.Count())
            .Select(g => g.Key)
            .Take(10)
            .ToListAsync(cancellationToken);

        var topSellers = await _productRepository.QueryAll()
            .Include(p => p.Category)
            .Include(p => p.Supplier)
            .Where(p => topSellerIds.Contains(p.Id) && p.StockQuantity > 0)
            .ToListAsync(cancellationToken);

        return topSellers
            .OrderBy(p => topSellerIds.IndexOf(p.Id))
            .Select(ProductMappings.ToResponse)
            .ToList();
    }
}
