using MediatR;
using Stronghold.Application.Interfaces;
using Stronghold.Domain.Exceptions;

namespace Stronghold.Application.Features.ProductCategories.GetProductCategoryById;

public class GetProductCategoryByIdQueryHandler : IRequestHandler<GetProductCategoryByIdQuery, ProductCategoryResponse>
{
    private readonly IProductCategoryRepository _categoryRepository;

    public GetProductCategoryByIdQueryHandler(IProductCategoryRepository categoryRepository)
    {
        _categoryRepository = categoryRepository;
    }

    public async Task<ProductCategoryResponse> Handle(GetProductCategoryByIdQuery request, CancellationToken cancellationToken)
    {
        var category = await _categoryRepository.GetByIdAsync(request.Id)
            ?? throw new NotFoundException("Kategorija proizvoda", request.Id);

        return ProductCategoryMappings.ToResponse(category);
    }
}
