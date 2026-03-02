namespace Stronghold.Core.Entities;

public class StockLog : BaseEntity
{
    public int SupplementId { get; set; }
    public int QuantityChange { get; set; }
    public int QuantityBefore { get; set; }
    public int QuantityAfter { get; set; }
    public string Reason { get; set; } = string.Empty;
    public int? RelatedOrderId { get; set; }
    public int? PerformedByUserId { get; set; }

    // Navigation properties
    public Supplement Supplement { get; set; } = null!;
    public Order? RelatedOrder { get; set; }
    public User? PerformedByUser { get; set; }
}
