using MediatR;
using Stronghold.Application.Interfaces;
using Stronghold.Domain.Entities;
using Stronghold.Domain.Exceptions;

namespace Stronghold.Application.Features.Cart.AddToCart;

public class AddToCartCommandHandler : IRequestHandler<AddToCartCommand, CartItemResponse>
{
    private readonly ICartItemRepository _cartItemRepository;
    private readonly IProductRepository _productRepository;
    private readonly ICurrentUserService _currentUserService;

    public AddToCartCommandHandler(
        ICartItemRepository cartItemRepository,
        IProductRepository productRepository,
        ICurrentUserService currentUserService)
    {
        _cartItemRepository = cartItemRepository;
        _productRepository = productRepository;
        _currentUserService = currentUserService;
    }

    public async Task<CartItemResponse> Handle(AddToCartCommand request, CancellationToken cancellationToken)
    {
        var product = await _productRepository.GetByIdWithDetailsAsync(request.ProductId)
            ?? throw new NotFoundException("Proizvod", request.ProductId);

        if (product.StockQuantity < request.Quantity)
            throw new InvalidOperationException("Nema dovoljno proizvoda na stanju.");

        var existingItem = await _cartItemRepository.GetByUserAndProductAsync(_currentUserService.UserId, request.ProductId);

        if (existingItem != null)
        {
            existingItem.Quantity += request.Quantity;
            _cartItemRepository.Update(existingItem);
            await _cartItemRepository.SaveChangesAsync();

            existingItem.Product = product;
            return CartMappings.ToItemResponse(existingItem);
        }

        var cartItem = new CartItem
        {
            UserId = _currentUserService.UserId,
            ProductId = request.ProductId,
            Quantity = request.Quantity
        };

        await _cartItemRepository.AddAsync(cartItem);
        await _cartItemRepository.SaveChangesAsync();

        cartItem.Product = product;
        return CartMappings.ToItemResponse(cartItem);
    }
}
