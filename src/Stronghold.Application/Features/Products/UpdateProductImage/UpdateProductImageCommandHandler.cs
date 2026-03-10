using MediatR;
using Stronghold.Application.Interfaces;
using Stronghold.Domain.Exceptions;

namespace Stronghold.Application.Features.Products.UpdateProductImage;

public class UpdateProductImageCommandHandler : IRequestHandler<UpdateProductImageCommand, ProductResponse>
{
    private readonly IProductRepository _productRepository;
    private readonly IFileService _fileService;

    public UpdateProductImageCommandHandler(IProductRepository productRepository, IFileService fileService)
    {
        _productRepository = productRepository;
        _fileService = fileService;
    }

    public async Task<ProductResponse> Handle(UpdateProductImageCommand request, CancellationToken cancellationToken)
    {
        var product = await _productRepository.GetByIdWithDetailsAsync(request.Id)
            ?? throw new NotFoundException("Proizvod", request.Id);

        if (!string.IsNullOrEmpty(product.ImageUrl))
            _fileService.Delete(product.ImageUrl);

        product.ImageUrl = await _fileService.UploadAsync(request.FileStream, request.FileName, "product-images");

        _productRepository.Update(product);
        await _productRepository.SaveChangesAsync();

        return ProductMappings.ToResponse(product);
    }
}
