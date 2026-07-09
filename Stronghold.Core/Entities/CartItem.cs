namespace Stronghold.Core.Entities;

/// <summary>
/// Stavka korpe clana - korpa zivi na serveru (radi na vise uredjaja),
/// narudzba i dalje nastaje tek nakon uspjesnog placanja.
/// </summary>
public class CartItem : BaseEntity
{
    public int UserId { get; set; }
    public User User { get; set; } = null!;
    public int SupplementId { get; set; }
    public Supplement Supplement { get; set; } = null!;
    public int Quantity { get; set; }
    public DateTime AddedAt { get; set; }
}
