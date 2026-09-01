using Stronghold.Core.Enums;

namespace Stronghold.Core.Entities;

// Nastaje kao PendingPayment zapis checkouta prije Stripe naplate (zakljucane stavke,
// cijene i valuta), a potvrdom placanja prelazi u Processing.
public class Order : BaseEntity
{
    public int UserId { get; set; }
    public User User { get; set; } = null!;
    public DateTime CreatedAt { get; set; }
    public decimal TotalAmount { get; set; }
    public string Currency { get; set; } = "bam";
    public OrderStatus Status { get; set; }
    public string StripePaymentIntentId { get; set; } = null!;
    public string DeliveryStreet { get; set; } = null!;
    public int DeliveryCityId { get; set; }
    public City DeliveryCity { get; set; } = null!;
    public DateTime? StatusChangedAt { get; set; }
    public int? StatusChangedByUserId { get; set; }
    public string? CancellationReason { get; set; }

    public ICollection<OrderItem> Items { get; set; } = new List<OrderItem>();
}
