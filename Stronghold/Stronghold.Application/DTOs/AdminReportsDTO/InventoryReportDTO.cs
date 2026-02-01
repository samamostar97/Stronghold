namespace Stronghold.Application.DTOs.AdminReportsDTO;

public class InventoryReportDTO
{
    public List<SlowMovingProductDTO> SlowMovingProducts { get; set; } = new();
    public int TotalProducts { get; set; }
    public int SlowMovingCount { get; set; }
    public int DaysAnalyzed { get; set; }
}

public class SlowMovingProductDTO
{
    public int SupplementId { get; set; }
    public string Name { get; set; } = string.Empty;
    public string CategoryName { get; set; } = string.Empty;
    public decimal Price { get; set; }
    public int QuantitySold { get; set; }
    public int DaysSinceLastSale { get; set; }
}
