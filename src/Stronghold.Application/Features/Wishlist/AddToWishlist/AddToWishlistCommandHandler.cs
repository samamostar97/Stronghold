using MediatR;
using Stronghold.Application.Interfaces;
using Stronghold.Domain.Entities;
using Stronghold.Domain.Exceptions;

namespace Stronghold.Application.Features.Wishlist.AddToWishlist;

public class AddToWishlistCommandHandler : IRequestHandler<AddToWishlistCommand, WishlistItemResponse>
{
    private readonly IWishlistItemRepository _wishlistRepository;
    private readonly IProductRepository _productRepository;
    private readonly ICurrentUserService _currentUserService;

    public AddToWishlistCommandHandler(
        IWishlistItemRepository wishlistRepository,
        IProductRepository productRepository,
        ICurrentUserService currentUserService)
    {
        _wishlistRepository = wishlistRepository;
        _productRepository = productRepository;
        _currentUserService = currentUserService;
    }

    public async Task<WishlistItemResponse> Handle(AddToWishlistCommand request, CancellationToken cancellationToken)
    {
        var product = await _productRepository.GetByIdWithDetailsAsync(request.ProductId)
            ?? throw new NotFoundException("Proizvod", request.ProductId);

        var existing = await _wishlistRepository.GetByUserAndProductAsync(_currentUserService.UserId, request.ProductId);
        if (existing != null)
            throw new ConflictException("Proizvod je već na wishlisti.");

        var wishlistItem = new WishlistItem
        {
            UserId = _currentUserService.UserId,
            ProductId = request.ProductId
        };

        await _wishlistRepository.AddAsync(wishlistItem);
        await _wishlistRepository.SaveChangesAsync();

        wishlistItem.Product = product;
        return WishlistMappings.ToResponse(wishlistItem);
    }
}
