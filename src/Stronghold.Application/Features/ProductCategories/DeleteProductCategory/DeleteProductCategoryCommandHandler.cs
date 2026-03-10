using MediatR;
using Stronghold.Application.Interfaces;
using Stronghold.Domain.Exceptions;

namespace Stronghold.Application.Features.ProductCategories.DeleteProductCategory;

public class DeleteProductCategoryCommandHandler : IRequestHandler<DeleteProductCategoryCommand, Unit>
{
    private readonly IProductCategoryRepository _categoryRepository;

    public DeleteProductCategoryCommandHandler(IProductCategoryRepository categoryRepository)
    {
        _categoryRepository = categoryRepository;
    }

    public async Task<Unit> Handle(DeleteProductCategoryCommand request, CancellationToken cancellationToken)
    {
        var category = await _categoryRepository.GetByIdAsync(request.Id)
            ?? throw new NotFoundException("Kategorija proizvoda", request.Id);

        _categoryRepository.Remove(category);
        await _categoryRepository.SaveChangesAsync();

        return Unit.Value;
    }
}
