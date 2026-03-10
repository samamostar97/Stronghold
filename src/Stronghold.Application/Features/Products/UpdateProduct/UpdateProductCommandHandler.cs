using MediatR;
using Stronghold.Application.Interfaces;
using Stronghold.Domain.Exceptions;

namespace Stronghold.Application.Features.Products.UpdateProduct;

public class UpdateProductCommandHandler : IRequestHandler<UpdateProductCommand, ProductResponse>
{
    private readonly IProductRepository _productRepository;
    private readonly IProductCategoryRepository _categoryRepository;
    private readonly ISupplierRepository _supplierRepository;

    public UpdateProductCommandHandler(
        IProductRepository productRepository,
        IProductCategoryRepository categoryRepository,
        ISupplierRepository supplierRepository)
    {
        _productRepository = productRepository;
        _categoryRepository = categoryRepository;
        _supplierRepository = supplierRepository;
    }

    public async Task<ProductResponse> Handle(UpdateProductCommand request, CancellationToken cancellationToken)
    {
        var product = await _productRepository.GetByIdWithDetailsAsync(request.Id)
            ?? throw new NotFoundException("Proizvod", request.Id);

        var category = await _categoryRepository.GetByIdAsync(request.CategoryId)
            ?? throw new NotFoundException("Kategorija proizvoda", request.CategoryId);

        var supplier = await _supplierRepository.GetByIdAsync(request.SupplierId)
            ?? throw new NotFoundException("Dobavljač", request.SupplierId);

        product.Name = request.Name;
        product.Description = request.Description;
        product.Price = request.Price;
        product.StockQuantity = request.StockQuantity;
        product.CategoryId = request.CategoryId;
        product.SupplierId = request.SupplierId;
        product.Category = category;
        product.Supplier = supplier;

        _productRepository.Update(product);
        await _productRepository.SaveChangesAsync();

        return ProductMappings.ToResponse(product);
    }
}
