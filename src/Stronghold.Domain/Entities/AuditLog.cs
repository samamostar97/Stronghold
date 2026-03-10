namespace Stronghold.Domain.Entities;

public class AuditLog
{
    public int Id { get; set; }
    public int AdminUserId { get; set; }
    public User AdminUser { get; set; } = null!;
    public string Action { get; set; } = "Delete";
    public string EntityType { get; set; } = string.Empty;
    public int EntityId { get; set; }
    public string EntitySnapshot { get; set; } = string.Empty;
    public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
    public DateTime CanUndoUntil { get; set; }
}
