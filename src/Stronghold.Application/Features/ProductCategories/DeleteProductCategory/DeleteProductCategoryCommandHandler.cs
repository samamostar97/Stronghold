using MediatR;
using Stronghold.Application.Interfaces;
using Stronghold.Domain.Exceptions;

namespace Stronghold.Application.Features.ProductCategories.DeleteProductCategory;

public class DeleteProductCategoryCommandHandler : IRequestHandler<DeleteProductCategoryCommand, Unit>
{
    private readonly IProductCategoryRepository _categoryRepository;
    private readonly IAuditService _auditService;
    private readonly ICurrentUserService _currentUserService;

    public DeleteProductCategoryCommandHandler(
        IProductCategoryRepository categoryRepository,
        IAuditService auditService,
        ICurrentUserService currentUserService)
    {
        _categoryRepository = categoryRepository;
        _auditService = auditService;
        _currentUserService = currentUserService;
    }

    public async Task<Unit> Handle(DeleteProductCategoryCommand request, CancellationToken cancellationToken)
    {
        var category = await _categoryRepository.GetByIdAsync(request.Id)
            ?? throw new NotFoundException("Kategorija proizvoda", request.Id);

        await _auditService.LogDeleteAsync(_currentUserService.UserId, "ProductCategory", category.Id, category);

        _categoryRepository.Remove(category);
        await _categoryRepository.SaveChangesAsync();

        return Unit.Value;
    }
}
