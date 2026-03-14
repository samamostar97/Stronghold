using Stronghold.Domain.Entities;

namespace Stronghold.Application.Features.Orders;

public static class OrderMappings
{
    public static OrderResponse ToResponse(Order order, string? clientSecret = null) => new()
    {
        Id = order.Id,
        UserId = order.UserId,
        UserName = !string.IsNullOrEmpty(order.UserFullName) ? order.UserFullName
            : order.User != null ? $"{order.User.FirstName} {order.User.LastName}" : string.Empty,
        TotalAmount = order.TotalAmount,
        DeliveryAddress = order.DeliveryAddress,
        Status = order.Status.ToString(),
        StripePaymentIntentId = order.StripePaymentIntentId,
        ClientSecret = clientSecret,
        CreatedAt = order.CreatedAt,
        Items = order.Items?.Select(ToItemResponse).ToList() ?? new()
    };

    public static OrderItemResponse ToItemResponse(OrderItem item) => new()
    {
        Id = item.Id,
        ProductId = item.ProductId,
        ProductName = !string.IsNullOrEmpty(item.ProductName) ? item.ProductName
            : item.Product?.Name ?? string.Empty,
        ProductImageUrl = item.ProductImageUrl ?? item.Product?.ImageUrl,
        Quantity = item.Quantity,
        UnitPrice = item.UnitPrice,
        Subtotal = item.UnitPrice * item.Quantity
    };
}
