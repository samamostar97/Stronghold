namespace Stronghold.Messaging.Events;

public class UserLevelUpEvent
{
    public string Email { get; set; } = default!;
    public string FirstName { get; set; } = default!;
    public string LevelName { get; set; } = default!;
}
