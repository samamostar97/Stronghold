namespace Stronghold.Application.DTOs.Reports;

/// <summary>Tab "Inventar" - stanje zaliha i vrijednost.</summary>
public class InventoryReportResponse
{
    public List<InventoryItem> Items { get; set; } = new();
    public decimal TotalValue { get; set; }
    public int LowStockCount { get; set; }
}

public class InventoryItem
{
    public string Name { get; set; } = null!;
    public string CategoryName { get; set; } = null!;
    public string SupplierName { get; set; } = null!;
    public int StockQuantity { get; set; }
    public decimal Price { get; set; }
    public decimal StockValue { get; set; }
}
