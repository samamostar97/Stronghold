namespace Stronghold.Application.Features.Supplements.DTOs;

public class SupplementResponse
{
    public int Id { get; set; }
    public string Name { get; set; } = string.Empty;
    public decimal Price { get; set; }
    public string? Description { get; set; }
    public int SupplementCategoryId { get; set; }
    public string SupplementCategoryName { get; set; } = string.Empty;
    public int SupplierId { get; set; }
    public string SupplierName { get; set; } = string.Empty;
    public string? ImageUrl { get; set; }
    public DateTime CreatedAt { get; set; }
}
