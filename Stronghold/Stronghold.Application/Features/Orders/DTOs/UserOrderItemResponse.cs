namespace Stronghold.Application.Features.Orders.DTOs;

public class UserOrderItemResponse
{
    public int Id { get; set; }
    public string SupplementName { get; set; } = string.Empty;
    public int Quantity { get; set; }
    public decimal UnitPrice { get; set; }
    public decimal TotalPrice => Quantity * UnitPrice;
}
