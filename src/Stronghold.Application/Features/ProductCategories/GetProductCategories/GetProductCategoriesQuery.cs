using MediatR;

namespace Stronghold.Application.Features.ProductCategories.GetProductCategories;

public class GetProductCategoriesQuery : IRequest<List<ProductCategoryResponse>>
{
}
