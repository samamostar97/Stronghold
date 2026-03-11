namespace Stronghold.Messaging.Events;

public class MembershipAssignedEvent
{
    public string Email { get; set; } = default!;
    public string FirstName { get; set; } = default!;
    public string PackageName { get; set; } = default!;
    public DateTime EndDate { get; set; }
}
