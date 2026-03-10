using Stronghold.Domain.Entities;

namespace Stronghold.Application.Features.ProductCategories;

public static class ProductCategoryMappings
{
    public static ProductCategoryResponse ToResponse(ProductCategory category) => new()
    {
        Id = category.Id,
        Name = category.Name,
        Description = category.Description
    };
}
