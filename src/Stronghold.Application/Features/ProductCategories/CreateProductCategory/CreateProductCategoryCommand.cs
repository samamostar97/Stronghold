using MediatR;
using Stronghold.Application.Common;

namespace Stronghold.Application.Features.ProductCategories.CreateProductCategory;

[AuthorizeRole("Admin")]
public class CreateProductCategoryCommand : IRequest<ProductCategoryResponse>
{
    public string Name { get; set; } = string.Empty;
    public string? Description { get; set; }
}
