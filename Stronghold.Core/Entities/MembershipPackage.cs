namespace Stronghold.Core.Entities;

public class MembershipPackage : BaseEntity
{
    public string Name { get; set; } = null!;
    public decimal Price { get; set; }
    public int DurationDays { get; set; }
    public string Description { get; set; } = null!;

    public ICollection<Membership> Memberships { get; set; } = new List<Membership>();
}
