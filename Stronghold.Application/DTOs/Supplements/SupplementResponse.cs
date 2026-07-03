namespace Stronghold.Application.DTOs.Supplements;

public class SupplementResponse
{
    public int Id { get; set; }
    public string Name { get; set; } = null!;
    public decimal Price { get; set; }
    public string Description { get; set; } = null!;
    public int CategoryId { get; set; }
    public string CategoryName { get; set; } = null!;
    public int SupplierId { get; set; }
    public string SupplierName { get; set; } = null!;
    public int StockQuantity { get; set; }
    public bool HasImage { get; set; }
    public double AverageRating { get; set; }
    public int ReviewCount { get; set; }
}
