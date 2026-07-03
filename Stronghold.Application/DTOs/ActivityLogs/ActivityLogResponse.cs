namespace Stronghold.Application.DTOs.ActivityLogs;

public class ActivityLogResponse
{
    public int Id { get; set; }
    public string EntityName { get; set; } = null!;
    public string? EntityDisplay { get; set; }
    public int EntityId { get; set; }
    public string Action { get; set; } = null!;
    public string PerformedByName { get; set; } = null!;
    public DateTime Timestamp { get; set; }
    public DateTime? UndoneAt { get; set; }
    /// <summary>Undo je moguc 1h od akcije, samo za jednostavne entitete.</summary>
    public bool CanUndo { get; set; }
}
