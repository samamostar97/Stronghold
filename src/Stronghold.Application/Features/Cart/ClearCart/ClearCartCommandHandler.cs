using MediatR;
using Stronghold.Application.Interfaces;

namespace Stronghold.Application.Features.Cart.ClearCart;

public class ClearCartCommandHandler : IRequestHandler<ClearCartCommand, Unit>
{
    private readonly ICartItemRepository _cartItemRepository;
    private readonly ICurrentUserService _currentUserService;

    public ClearCartCommandHandler(ICartItemRepository cartItemRepository, ICurrentUserService currentUserService)
    {
        _cartItemRepository = cartItemRepository;
        _currentUserService = currentUserService;
    }

    public async Task<Unit> Handle(ClearCartCommand request, CancellationToken cancellationToken)
    {
        await _cartItemRepository.ClearCartAsync(_currentUserService.UserId);
        await _cartItemRepository.SaveChangesAsync();

        return Unit.Value;
    }
}
