using Stronghold.Core.Enums;

namespace Stronghold.Core.Entities;

public class Notification : BaseEntity
{
    public int UserId { get; set; }
    public User User { get; set; } = null!;
    public string Title { get; set; } = null!;
    public string Message { get; set; } = null!;
    public NotificationType Type { get; set; }
    public bool IsRead { get; set; }
    public DateTime CreatedAt { get; set; }
}
