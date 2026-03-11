namespace Stronghold.Messaging.Events;

public class UserRegisteredEvent
{
    public string Email { get; set; } = default!;
    public string FirstName { get; set; } = default!;
}
