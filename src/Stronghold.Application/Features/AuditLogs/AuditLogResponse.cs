namespace Stronghold.Application.Features.AuditLogs;

public class AuditLogResponse
{
    public int Id { get; set; }
    public int AdminUserId { get; set; }
    public string AdminUsername { get; set; } = string.Empty;
    public string Action { get; set; } = string.Empty;
    public string EntityType { get; set; } = string.Empty;
    public int EntityId { get; set; }
    public string EntitySnapshot { get; set; } = string.Empty;
    public DateTime CreatedAt { get; set; }
    public DateTime CanUndoUntil { get; set; }
    public bool CanUndo { get; set; }
}
