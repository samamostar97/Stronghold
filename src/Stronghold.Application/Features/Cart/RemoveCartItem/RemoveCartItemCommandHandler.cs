using MediatR;
using Stronghold.Application.Interfaces;
using Stronghold.Domain.Exceptions;

namespace Stronghold.Application.Features.Cart.RemoveCartItem;

public class RemoveCartItemCommandHandler : IRequestHandler<RemoveCartItemCommand, Unit>
{
    private readonly ICartItemRepository _cartItemRepository;
    private readonly ICurrentUserService _currentUserService;

    public RemoveCartItemCommandHandler(ICartItemRepository cartItemRepository, ICurrentUserService currentUserService)
    {
        _cartItemRepository = cartItemRepository;
        _currentUserService = currentUserService;
    }

    public async Task<Unit> Handle(RemoveCartItemCommand request, CancellationToken cancellationToken)
    {
        var cartItem = await _cartItemRepository.GetByIdAsync(request.Id)
            ?? throw new NotFoundException("Stavka korpe", request.Id);

        if (cartItem.UserId != _currentUserService.UserId)
            throw new ForbiddenException("Nemate pristup ovoj stavci.");

        _cartItemRepository.HardRemove(cartItem);
        await _cartItemRepository.SaveChangesAsync();

        return Unit.Value;
    }
}
