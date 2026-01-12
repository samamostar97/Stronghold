namespace Stronghold.Core.Entities;

public class Review : BaseEntity
{
    public int UserId { get; set; }
    public int SupplementId { get; set; }
    public int Rating { get; set; }
    public string? Comment { get; set; }

    // Navigation properties
    public User User { get; set; } = null!;
    public Supplement Supplement { get; set; } = null!;
}
