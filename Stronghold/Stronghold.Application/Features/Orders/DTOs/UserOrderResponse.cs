using Stronghold.Core.Enums;

namespace Stronghold.Application.Features.Orders.DTOs;

public class UserOrderResponse
{
    public int Id { get; set; }

public decimal TotalAmount { get; set; }

public DateTime PurchaseDate { get; set; }

public OrderStatus Status { get; set; }

public string StatusName => Status.ToString();
    public DateTime? CancelledAt { get; set; }

public string? CancellationReason { get; set; }

public List<UserOrderItemResponse> OrderItems { get; set; } = new();
}
