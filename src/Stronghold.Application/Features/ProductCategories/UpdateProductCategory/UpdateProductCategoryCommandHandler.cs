using MediatR;
using Stronghold.Application.Interfaces;
using Stronghold.Domain.Exceptions;

namespace Stronghold.Application.Features.ProductCategories.UpdateProductCategory;

public class UpdateProductCategoryCommandHandler : IRequestHandler<UpdateProductCategoryCommand, ProductCategoryResponse>
{
    private readonly IProductCategoryRepository _categoryRepository;

    public UpdateProductCategoryCommandHandler(IProductCategoryRepository categoryRepository)
    {
        _categoryRepository = categoryRepository;
    }

    public async Task<ProductCategoryResponse> Handle(UpdateProductCategoryCommand request, CancellationToken cancellationToken)
    {
        var category = await _categoryRepository.GetByIdAsync(request.Id)
            ?? throw new NotFoundException("Kategorija proizvoda", request.Id);

        var existing = await _categoryRepository.FindAsync(c => c.Name == request.Name && c.Id != request.Id);
        if (existing.Any())
            throw new ConflictException("Kategorija sa ovim nazivom već postoji.");

        category.Name = request.Name;
        category.Description = request.Description;

        _categoryRepository.Update(category);
        await _categoryRepository.SaveChangesAsync();

        return ProductCategoryMappings.ToResponse(category);
    }
}
