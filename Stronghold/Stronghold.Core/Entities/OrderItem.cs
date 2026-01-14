namespace Stronghold.Core.Entities;

public class OrderItem : BaseEntity
{
    public int OrderId { get; set; }
    public int SupplementId { get; set; }
    public int Quantity { get; set; }
    public decimal UnitPrice { get; set; }

    // Navigation properties
    public Order Order { get; set; } = null!;
    public Supplement Supplement { get; set; } = null!;
}
