namespace Stronghold.Core.Entities;

public class Payment : BaseEntity
{
    public int MembershipId { get; set; }
    public Membership Membership { get; set; } = null!;
    public decimal Amount { get; set; }
    public DateTime PaidAt { get; set; }
}
