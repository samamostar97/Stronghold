namespace Stronghold.Application.DTOs.Reports;

/// <summary>Tab "Inventar" - stanje zaliha, doseg zaliha i najlosije ocijenjeni proizvodi.</summary>
public class InventoryReportResponse
{
    public List<InventoryItem> Items { get; set; } = new();
    public List<WorstRatedProduct> WorstRated { get; set; } = new();
    public decimal TotalValue { get; set; }
    public int TotalItems { get; set; }
    public int LowStockCount { get; set; }
    public int OutOfStockCount { get; set; }

    /// <summary>Artikli bez ijedne prodaje u zadnjih 30 dana.</summary>
    public int NoSalesLast30Count { get; set; }
}

public class InventoryItem
{
    public string Name { get; set; } = null!;
    public string CategoryName { get; set; } = null!;
    public string SupplierName { get; set; } = null!;
    public int StockQuantity { get; set; }
    public int SoldLast30Days { get; set; }
    public decimal Price { get; set; }
    public decimal StockValue { get; set; }

    /// <summary>Procjena za koliko dana zalihe nestaju po tempu prodaje 30 dana; null bez prodaje.</summary>
    public double? StockCoverDays { get; set; }
}

public class WorstRatedProduct
{
    public string Name { get; set; } = null!;
    public double AverageRating { get; set; }
    public int ReviewCount { get; set; }
    public int SoldLast30Days { get; set; }
}
