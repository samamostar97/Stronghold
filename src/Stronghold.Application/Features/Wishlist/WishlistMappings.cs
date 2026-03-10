using Stronghold.Domain.Entities;

namespace Stronghold.Application.Features.Wishlist;

public static class WishlistMappings
{
    public static WishlistItemResponse ToResponse(WishlistItem item) => new()
    {
        Id = item.Id,
        ProductId = item.ProductId,
        ProductName = item.Product?.Name ?? string.Empty,
        ProductPrice = item.Product?.Price ?? 0,
        ProductImageUrl = item.Product?.ImageUrl,
        CreatedAt = item.CreatedAt
    };
}
