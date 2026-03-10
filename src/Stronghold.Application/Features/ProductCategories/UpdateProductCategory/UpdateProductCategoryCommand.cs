using MediatR;
using Stronghold.Application.Common;

namespace Stronghold.Application.Features.ProductCategories.UpdateProductCategory;

[AuthorizeRole("Admin")]
public class UpdateProductCategoryCommand : IRequest<ProductCategoryResponse>
{
    public int Id { get; set; }
    public string Name { get; set; } = string.Empty;
    public string? Description { get; set; }
}
