namespace Stronghold.Messaging.Events;

public class MembershipExpiredEvent
{
    public string Email { get; set; } = default!;
    public string FirstName { get; set; } = default!;
    public string PackageName { get; set; } = default!;
}
