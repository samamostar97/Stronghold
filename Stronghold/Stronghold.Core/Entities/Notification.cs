namespace Stronghold.Core.Entities;

public class Notification : BaseEntity
{
    public int? UserId { get; set; }
    public string Type { get; set; } = string.Empty;
    public string Title { get; set; } = string.Empty;
    public string Message { get; set; } = string.Empty;
    public bool IsRead { get; set; }
    public int? RelatedEntityId { get; set; }
    public string? RelatedEntityType { get; set; }

    // Navigation property
    public User? User { get; set; }
}
