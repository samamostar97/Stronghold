using MediatR;
using Stronghold.Application.Interfaces;

namespace Stronghold.Application.Features.Cart.GetCart;

public class GetCartQueryHandler : IRequestHandler<GetCartQuery, CartResponse>
{
    private readonly ICartItemRepository _cartItemRepository;
    private readonly ICurrentUserService _currentUserService;

    public GetCartQueryHandler(ICartItemRepository cartItemRepository, ICurrentUserService currentUserService)
    {
        _cartItemRepository = cartItemRepository;
        _currentUserService = currentUserService;
    }

    public async Task<CartResponse> Handle(GetCartQuery request, CancellationToken cancellationToken)
    {
        var items = await _cartItemRepository.GetByUserIdAsync(_currentUserService.UserId);
        return CartMappings.ToCartResponse(items);
    }
}
