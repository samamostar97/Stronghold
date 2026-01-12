namespace Stronghold.Core.Entities;

public class Order : BaseEntity
{
    public int UserId { get; set; }
    public int SupplementId { get; set; }
    public decimal Amount { get; set; }
    public DateTime PurchaseDate { get; set; }
    public bool IsDelivered { get; set; }
    public string? StripePaymentId { get; set; }

    // Navigation properties
    public User User { get; set; } = null!;
    public Supplement Supplement { get; set; } = null!;
}
