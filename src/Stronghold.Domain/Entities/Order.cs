using Stronghold.Domain.Enums;

namespace Stronghold.Domain.Entities;

public class Order : BaseEntity
{
    public int UserId { get; set; }
    public User User { get; set; } = null!;
    public decimal TotalAmount { get; set; }
    public string DeliveryAddress { get; set; } = string.Empty;
    public OrderStatus Status { get; set; } = OrderStatus.Pending;
    public string? StripePaymentIntentId { get; set; }
    public List<OrderItem> Items { get; set; } = new();
}
