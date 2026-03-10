using Stronghold.Domain.Entities;

namespace Stronghold.Application.Features.Products;

public static class ProductMappings
{
    public static ProductResponse ToResponse(Product product) => new()
    {
        Id = product.Id,
        Name = product.Name,
        Description = product.Description,
        Price = product.Price,
        ImageUrl = product.ImageUrl,
        StockQuantity = product.StockQuantity,
        CategoryId = product.CategoryId,
        CategoryName = product.Category?.Name ?? string.Empty,
        SupplierId = product.SupplierId,
        SupplierName = product.Supplier?.Name ?? string.Empty,
        CreatedAt = product.CreatedAt
    };
}
