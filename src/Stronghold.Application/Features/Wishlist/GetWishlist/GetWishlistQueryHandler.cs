using MediatR;
using Stronghold.Application.Interfaces;

namespace Stronghold.Application.Features.Wishlist.GetWishlist;

public class GetWishlistQueryHandler : IRequestHandler<GetWishlistQuery, List<WishlistItemResponse>>
{
    private readonly IWishlistItemRepository _wishlistRepository;
    private readonly ICurrentUserService _currentUserService;

    public GetWishlistQueryHandler(IWishlistItemRepository wishlistRepository, ICurrentUserService currentUserService)
    {
        _wishlistRepository = wishlistRepository;
        _currentUserService = currentUserService;
    }

    public async Task<List<WishlistItemResponse>> Handle(GetWishlistQuery request, CancellationToken cancellationToken)
    {
        var items = await _wishlistRepository.GetByUserIdAsync(_currentUserService.UserId);
        return items.Select(WishlistMappings.ToResponse).ToList();
    }
}
