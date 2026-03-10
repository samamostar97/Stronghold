using MediatR;
using Stronghold.Application.Interfaces;

namespace Stronghold.Application.Features.ProductCategories.GetProductCategories;

public class GetProductCategoriesQueryHandler : IRequestHandler<GetProductCategoriesQuery, List<ProductCategoryResponse>>
{
    private readonly IProductCategoryRepository _categoryRepository;

    public GetProductCategoriesQueryHandler(IProductCategoryRepository categoryRepository)
    {
        _categoryRepository = categoryRepository;
    }

    public async Task<List<ProductCategoryResponse>> Handle(GetProductCategoriesQuery request, CancellationToken cancellationToken)
    {
        var categories = await _categoryRepository.GetAllAsync();
        return categories.Select(ProductCategoryMappings.ToResponse).ToList();
    }
}
