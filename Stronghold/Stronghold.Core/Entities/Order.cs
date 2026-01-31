using Stronghold.Core.Enums;

namespace Stronghold.Core.Entities;

public class Order : BaseEntity
{
    public int UserId { get; set; }
    public decimal TotalAmount { get; set; }
    public DateTime PurchaseDate { get; set; }
    public OrderStatus Status { get; set; } = OrderStatus.Processing;
    public string? StripePaymentId { get; set; }

    // Navigation properties
    public User User { get; set; } = null!;
    public ICollection<OrderItem> OrderItems { get; set; } = new List<OrderItem>();
}
