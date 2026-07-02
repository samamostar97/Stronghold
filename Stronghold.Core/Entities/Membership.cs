namespace Stronghold.Core.Entities;

/// <summary>
/// Status "aktivna/istekla" se ne pohranjuje - racuna se iz EndDate i IsRevoked.
/// </summary>
public class Membership : BaseEntity
{
    public int UserId { get; set; }
    public User User { get; set; } = null!;
    public int PackageId { get; set; }
    public MembershipPackage Package { get; set; } = null!;
    public DateTime StartDate { get; set; }
    public DateTime EndDate { get; set; }
    public bool IsRevoked { get; set; }
    public DateTime? RevokedAt { get; set; }
    public string? RevocationReason { get; set; }

    public ICollection<Payment> Payments { get; set; } = new List<Payment>();
}
