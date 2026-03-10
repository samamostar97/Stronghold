using MediatR;
using Stronghold.Application.Interfaces;
using Stronghold.Domain.Entities;
using Stronghold.Domain.Exceptions;

namespace Stronghold.Application.Features.ProductCategories.CreateProductCategory;

public class CreateProductCategoryCommandHandler : IRequestHandler<CreateProductCategoryCommand, ProductCategoryResponse>
{
    private readonly IProductCategoryRepository _categoryRepository;

    public CreateProductCategoryCommandHandler(IProductCategoryRepository categoryRepository)
    {
        _categoryRepository = categoryRepository;
    }

    public async Task<ProductCategoryResponse> Handle(CreateProductCategoryCommand request, CancellationToken cancellationToken)
    {
        var existing = await _categoryRepository.FindAsync(c => c.Name == request.Name);
        if (existing.Any())
            throw new ConflictException("Kategorija sa ovim nazivom već postoji.");

        var category = new ProductCategory
        {
            Name = request.Name,
            Description = request.Description
        };

        await _categoryRepository.AddAsync(category);
        await _categoryRepository.SaveChangesAsync();

        return ProductCategoryMappings.ToResponse(category);
    }
}
