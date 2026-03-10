using MediatR;

namespace Stronghold.Application.Features.ProductCategories.GetProductCategoryById;

public class GetProductCategoryByIdQuery : IRequest<ProductCategoryResponse>
{
    public int Id { get; set; }
}
