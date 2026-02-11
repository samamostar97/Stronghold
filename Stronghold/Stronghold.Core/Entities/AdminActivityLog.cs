namespace Stronghold.Core.Entities;

public class AdminActivityLog : BaseEntity
{
    public int AdminUserId { get; set; }
    public string AdminUsername { get; set; } = string.Empty;
    public string ActionType { get; set; } = string.Empty;
    public string EntityType { get; set; } = string.Empty;
    public int EntityId { get; set; }
    public string Description { get; set; } = string.Empty;
    public DateTime UndoAvailableUntil { get; set; }
    public bool IsUndone { get; set; }
    public DateTime? UndoneAt { get; set; }
    public int? UndoneByUserId { get; set; }
}
