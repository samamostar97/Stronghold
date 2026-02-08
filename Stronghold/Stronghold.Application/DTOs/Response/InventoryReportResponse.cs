namespace Stronghold.Application.DTOs.Response
{
    public class InventoryReportResponse
    {
        public List<SlowMovingProductResponse> SlowMovingProducts { get; set; } = new();
        public int TotalProducts { get; set; }
        public int SlowMovingCount { get; set; }
        public int DaysAnalyzed { get; set; }
    }

    /// <summary>
    /// Summary statistics for inventory report (without the products list)
    /// </summary>
    public class InventorySummaryResponse
    {
        public int TotalProducts { get; set; }
        public int SlowMovingCount { get; set; }
        public int DaysAnalyzed { get; set; }
    }

    public class SlowMovingProductResponse
    {
        public int SupplementId { get; set; }
        public string Name { get; set; } = string.Empty;
        public string CategoryName { get; set; } = string.Empty;
        public decimal Price { get; set; }
        public int QuantitySold { get; set; }
        public int DaysSinceLastSale { get; set; }
    }
}
