using MediatR;
using Microsoft.EntityFrameworkCore;
using Stronghold.Application.Interfaces;
using Stronghold.Domain.Exceptions;

namespace Stronghold.Application.Features.Cart.UpdateCartItem;

public class UpdateCartItemCommandHandler : IRequestHandler<UpdateCartItemCommand, CartItemResponse>
{
    private readonly ICartItemRepository _cartItemRepository;
    private readonly ICurrentUserService _currentUserService;

    public UpdateCartItemCommandHandler(ICartItemRepository cartItemRepository, ICurrentUserService currentUserService)
    {
        _cartItemRepository = cartItemRepository;
        _currentUserService = currentUserService;
    }

    public async Task<CartItemResponse> Handle(UpdateCartItemCommand request, CancellationToken cancellationToken)
    {
        var cartItem = await _cartItemRepository.QueryAll()
            .Include(c => c.Product)
            .FirstOrDefaultAsync(c => c.Id == request.Id && c.UserId == _currentUserService.UserId, cancellationToken)
            ?? throw new NotFoundException("Stavka korpe", request.Id);

        if (cartItem.Product.StockQuantity < request.Quantity)
            throw new InvalidOperationException("Nema dovoljno proizvoda na stanju.");

        cartItem.Quantity = request.Quantity;
        _cartItemRepository.Update(cartItem);
        await _cartItemRepository.SaveChangesAsync();

        return CartMappings.ToItemResponse(cartItem);
    }
}
