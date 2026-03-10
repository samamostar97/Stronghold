namespace Stronghold.Application.Features.ProductCategories;

public class ProductCategoryResponse
{
    public int Id { get; set; }
    public string Name { get; set; } = string.Empty;
    public string? Description { get; set; }
}
