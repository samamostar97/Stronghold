using Stronghold.Domain.Entities;

namespace Stronghold.Application.Features.Cart;

public static class CartMappings
{
    public static CartItemResponse ToItemResponse(CartItem item) => new()
    {
        Id = item.Id,
        ProductId = item.ProductId,
        ProductName = item.Product?.Name ?? string.Empty,
        ProductPrice = item.Product?.Price ?? 0,
        ProductImageUrl = item.Product?.ImageUrl,
        Quantity = item.Quantity,
        Subtotal = (item.Product?.Price ?? 0) * item.Quantity
    };

    public static CartResponse ToCartResponse(List<CartItem> items) => new()
    {
        Items = items.Select(ToItemResponse).ToList(),
        TotalPrice = items.Sum(i => (i.Product?.Price ?? 0) * i.Quantity)
    };
}
