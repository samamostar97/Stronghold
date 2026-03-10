using MediatR;
using Stronghold.Application.Common;

namespace Stronghold.Application.Features.ProductCategories.GetProductCategoryById;

[AuthorizeRole("Admin")]
[AuthorizeRole("User")]
public class GetProductCategoryByIdQuery : IRequest<ProductCategoryResponse>
{
    public int Id { get; set; }
}
