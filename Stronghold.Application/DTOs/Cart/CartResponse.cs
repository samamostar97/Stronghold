namespace Stronghold.Application.DTOs.Cart;

/// <summary>Kompletno stanje korpe - svaka mutacija vraca novo stanje.</summary>
public class CartResponse
{
    public List<CartItemResponse> Items { get; set; } = new();
    public decimal Total { get; set; }
}

public class CartItemResponse
{
    public int SupplementId { get; set; }
    public string Name { get; set; } = null!;
    public decimal Price { get; set; }
    public int StockQuantity { get; set; }
    public bool HasImage { get; set; }
    public int Quantity { get; set; }
    public decimal Subtotal { get; set; }
}
