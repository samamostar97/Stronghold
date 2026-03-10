using MediatR;
using Stronghold.Application.Interfaces;
using Stronghold.Domain.Exceptions;

namespace Stronghold.Application.Features.Wishlist.RemoveFromWishlist;

public class RemoveFromWishlistCommandHandler : IRequestHandler<RemoveFromWishlistCommand, Unit>
{
    private readonly IWishlistItemRepository _wishlistRepository;
    private readonly ICurrentUserService _currentUserService;

    public RemoveFromWishlistCommandHandler(IWishlistItemRepository wishlistRepository, ICurrentUserService currentUserService)
    {
        _wishlistRepository = wishlistRepository;
        _currentUserService = currentUserService;
    }

    public async Task<Unit> Handle(RemoveFromWishlistCommand request, CancellationToken cancellationToken)
    {
        var wishlistItem = await _wishlistRepository.GetByUserAndProductAsync(_currentUserService.UserId, request.ProductId)
            ?? throw new NotFoundException("Stavka wishliste", request.ProductId);

        _wishlistRepository.HardRemove(wishlistItem);
        await _wishlistRepository.SaveChangesAsync();

        return Unit.Value;
    }
}
