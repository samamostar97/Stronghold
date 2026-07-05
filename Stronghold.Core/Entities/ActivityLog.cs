using Stronghold.Core.Enums;

namespace Stronghold.Core.Entities;

// Snapshot starog stanja (JSON) omogucava undo u roku od 1h za jednostavne entitete.
public class ActivityLog : BaseEntity
{
    public string EntityName { get; set; } = null!;
    public int EntityId { get; set; }
    // Citljiv naziv zapisa u trenutku akcije (npr. naziv suplementa).
    public string? EntityDisplay { get; set; }
    public ActivityAction Action { get; set; }
    public string? OldDataJson { get; set; }
    public int PerformedByUserId { get; set; }
    public User PerformedBy { get; set; } = null!;
    public DateTime Timestamp { get; set; }
    // Postavljeno kada je akcija ponistena - undo se ne moze ponoviti.
    public DateTime? UndoneAt { get; set; }
}
