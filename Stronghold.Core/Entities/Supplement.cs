namespace Stronghold.Core.Entities;

public class Supplement : BaseEntity
{
    public string Name { get; set; } = null!;
    public byte[]? ImageData { get; set; }
    public decimal Price { get; set; }
    public string Description { get; set; } = null!;
    public int CategoryId { get; set; }
    public SupplementCategory Category { get; set; } = null!;
    public int SupplierId { get; set; }
    public Supplier Supplier { get; set; } = null!;
    public int StockQuantity { get; set; }

    public ICollection<OrderItem> OrderItems { get; set; } = new List<OrderItem>();
    public ICollection<Review> Reviews { get; set; } = new List<Review>();
}
