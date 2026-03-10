using MediatR;
using Stronghold.Application.Interfaces;
using Stronghold.Domain.Entities;
using Stronghold.Domain.Exceptions;

namespace Stronghold.Application.Features.Products.CreateProduct;

public class CreateProductCommandHandler : IRequestHandler<CreateProductCommand, ProductResponse>
{
    private readonly IProductRepository _productRepository;
    private readonly IProductCategoryRepository _categoryRepository;
    private readonly ISupplierRepository _supplierRepository;

    public CreateProductCommandHandler(
        IProductRepository productRepository,
        IProductCategoryRepository categoryRepository,
        ISupplierRepository supplierRepository)
    {
        _productRepository = productRepository;
        _categoryRepository = categoryRepository;
        _supplierRepository = supplierRepository;
    }

    public async Task<ProductResponse> Handle(CreateProductCommand request, CancellationToken cancellationToken)
    {
        var category = await _categoryRepository.GetByIdAsync(request.CategoryId)
            ?? throw new NotFoundException("Kategorija proizvoda", request.CategoryId);

        var supplier = await _supplierRepository.GetByIdAsync(request.SupplierId)
            ?? throw new NotFoundException("Dobavljač", request.SupplierId);

        var product = new Product
        {
            Name = request.Name,
            Description = request.Description,
            Price = request.Price,
            StockQuantity = request.StockQuantity,
            CategoryId = request.CategoryId,
            SupplierId = request.SupplierId
        };

        await _productRepository.AddAsync(product);
        await _productRepository.SaveChangesAsync();

        product.Category = category;
        product.Supplier = supplier;

        return ProductMappings.ToResponse(product);
    }
}
