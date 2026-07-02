namespace Stronghold.Core.Entities;

/// <summary>
/// Dozvoljena samo za suplement iz dostavljene narudzbe korisnika; jedna po (UserId, SupplementId).
/// </summary>
public class Review : BaseEntity
{
    public int UserId { get; set; }
    public User User { get; set; } = null!;
    public int SupplementId { get; set; }
    public Supplement Supplement { get; set; } = null!;
    public int Rating { get; set; }
    public string? Comment { get; set; }
    public DateTime CreatedAt { get; set; }
}
