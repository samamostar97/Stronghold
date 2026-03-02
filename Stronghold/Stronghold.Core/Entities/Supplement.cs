namespace Stronghold.Core.Entities;

public class Supplement : BaseEntity
{
    public string Name { get; set; } = string.Empty;
    public decimal Price { get; set; }
    public string? Description { get; set; }

    public int SupplementCategoryId { get; set; }
    public int SupplierId { get; set; }
    public string? SupplementImageUrl { get; set; }
    public int StockQuantity { get; set; }


    // Navigation properties
    public SupplementCategory SupplementCategory { get; set; } = null!;
    public Supplier Supplier { get; set; } = null!;
    public ICollection<Review> Reviews { get; set; } = new List<Review>();
}
