namespace Stronghold.Application.Features.Orders;

public class OrderResponse
{
    public int Id { get; set; }
    public int UserId { get; set; }
    public string UserName { get; set; } = string.Empty;
    public decimal TotalAmount { get; set; }
    public string DeliveryAddress { get; set; } = string.Empty;
    public string Status { get; set; } = string.Empty;
    public string? StripePaymentIntentId { get; set; }
    public string? ClientSecret { get; set; }
    public DateTime CreatedAt { get; set; }
    public List<OrderItemResponse> Items { get; set; } = new();
}
