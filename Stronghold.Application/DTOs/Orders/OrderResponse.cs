namespace Stronghold.Application.DTOs.Orders;

public class OrderResponse
{
    public int Id { get; set; }
    public int UserId { get; set; }
    public string UserFullName { get; set; } = null!;
    public DateTime CreatedAt { get; set; }
    public decimal TotalAmount { get; set; }
    public string Status { get; set; } = null!;
    public string StripePaymentIntentId { get; set; } = null!;
    public string DeliveryStreet { get; set; } = null!;
    public string DeliveryCityName { get; set; } = null!;
    public DateTime? StatusChangedAt { get; set; }
    public string? CancellationReason { get; set; }
    public List<OrderItemResponse> Items { get; set; } = new();
}

public class OrderItemResponse
{
    public int SupplementId { get; set; }
    public string SupplementName { get; set; } = null!;
    public int Quantity { get; set; }
    public decimal UnitPrice { get; set; }
}
