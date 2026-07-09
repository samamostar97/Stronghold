namespace Stronghold.Application.DTOs.Seminars;

public class SeminarResponse
{
    public int Id { get; set; }
    public string Topic { get; set; } = null!;
    public string Speaker { get; set; } = null!;
    public DateTime ScheduledAt { get; set; }
    public int MaxCapacity { get; set; }
    public int RegisteredCount { get; set; }
    public int RemainingCapacity { get; set; }
    public bool IsCancelled { get; set; }
    public string? CancellationReason { get; set; }
    /// <summary>Da li je trenutno prijavljeni korisnik vec prijavljen (za mobile dugme).</summary>
    public bool IsCurrentUserRegistered { get; set; }
}
