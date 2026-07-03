using Stronghold.Core.Enums;

namespace Stronghold.Core.Entities;

/// <summary>
/// Snapshot starog stanja (JSON) omogucava undo u roku od 1h za jednostavne entitete.
/// </summary>
public class ActivityLog : BaseEntity
{
    public string EntityName { get; set; } = null!;
    public int EntityId { get; set; }
    /// <summary>Citljiv naziv zapisa u trenutku akcije (npr. naziv suplementa).</summary>
    public string? EntityDisplay { get; set; }
    public ActivityAction Action { get; set; }
    public string? OldDataJson { get; set; }
    public int PerformedByUserId { get; set; }
    public User PerformedBy { get; set; } = null!;
    public DateTime Timestamp { get; set; }
    /// <summary>Postavljeno kada je akcija ponistena - undo se ne moze ponoviti.</summary>
    public DateTime? UndoneAt { get; set; }
}
