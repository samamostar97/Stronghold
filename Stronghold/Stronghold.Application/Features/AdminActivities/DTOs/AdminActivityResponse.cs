namespace Stronghold.Application.Features.AdminActivities.DTOs;

public class AdminActivityResponse
{
    public int Id { get; set; }
    public string ActionType { get; set; } = string.Empty;
    public string EntityType { get; set; } = string.Empty;
    public int EntityId { get; set; }
    public string Description { get; set; } = string.Empty;
    public string AdminUsername { get; set; } = string.Empty;
    public DateTime CreatedAt { get; set; }
    public DateTime UndoAvailableUntil { get; set; }
    public bool IsUndone { get; set; }
    public bool CanUndo { get; set; }
}
