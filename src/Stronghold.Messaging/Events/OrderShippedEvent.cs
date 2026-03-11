namespace Stronghold.Messaging.Events;

public class OrderShippedEvent
{
    public string Email { get; set; } = default!;
    public string FirstName { get; set; } = default!;
    public int OrderId { get; set; }
}
