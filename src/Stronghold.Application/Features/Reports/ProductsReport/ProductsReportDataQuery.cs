using MediatR;
using Microsoft.EntityFrameworkCore;
using Stronghold.Application.Common;
using Stronghold.Application.Interfaces;
using Stronghold.Domain.Enums;

namespace Stronghold.Application.Features.Reports.ProductsReport;

[AuthorizeRole("Admin")]
public class ProductsReportDataQuery : IRequest<ProductsReportData>
{
    public DateTime From { get; set; }
    public DateTime To { get; set; }
}

public class ProductsReportDataQueryHandler : IRequestHandler<ProductsReportDataQuery, ProductsReportData>
{
    private readonly IOrderRepository _orderRepository;
    private readonly IProductRepository _productRepository;

    public ProductsReportDataQueryHandler(
        IOrderRepository orderRepository,
        IProductRepository productRepository)
    {
        _orderRepository = orderRepository;
        _productRepository = productRepository;
    }

    public async Task<ProductsReportData> Handle(ProductsReportDataQuery request, CancellationToken cancellationToken)
    {
        var orders = await _orderRepository.QueryAll()
            .Include(o => o.Items).ThenInclude(i => i.Product).ThenInclude(p => p.Category)
            .Where(o => o.Status == OrderStatus.Confirmed || o.Status == OrderStatus.Shipped)
            .Where(o => o.CreatedAt >= request.From && o.CreatedAt <= request.To)
            .ToListAsync(cancellationToken);

        var topSelling = orders
            .SelectMany(o => o.Items)
            .GroupBy(i => new { i.ProductId, i.Product.Name, CategoryName = i.Product.Category?.Name ?? "-" })
            .Select(g => new TopSellingProductItem
            {
                ProductId = g.Key.ProductId,
                ProductName = g.Key.Name,
                CategoryName = g.Key.CategoryName,
                TotalQuantitySold = g.Sum(i => i.Quantity),
                TotalRevenue = g.Sum(i => i.Quantity * i.UnitPrice)
            })
            .OrderByDescending(p => p.TotalQuantitySold)
            .Take(20)
            .ToList();

        var products = await _productRepository.QueryAll()
            .Include(p => p.Category)
            .OrderBy(p => p.StockQuantity)
            .ToListAsync(cancellationToken);

        var stockLevels = products.Select(p => new StockLevelItem
        {
            ProductId = p.Id,
            ProductName = p.Name,
            CategoryName = p.Category?.Name ?? "-",
            StockQuantity = p.StockQuantity,
            Price = p.Price
        }).ToList();

        return new ProductsReportData
        {
            From = request.From,
            To = request.To,
            TopSelling = topSelling,
            StockLevels = stockLevels
        };
    }
}
