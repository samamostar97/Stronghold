namespace Stronghold.Messaging.Events;

public class OrderConfirmedEvent
{
    public string Email { get; set; } = default!;
    public string FirstName { get; set; } = default!;
    public int OrderId { get; set; }
    public decimal TotalAmount { get; set; }
}
