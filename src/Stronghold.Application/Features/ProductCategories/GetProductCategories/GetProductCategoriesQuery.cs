using MediatR;
using Stronghold.Application.Common;

namespace Stronghold.Application.Features.ProductCategories.GetProductCategories;

[AuthorizeRole("Admin")]
[AuthorizeRole("User")]
public class GetProductCategoriesQuery : IRequest<List<ProductCategoryResponse>>
{
}
