namespace Stronghold.Core.Entities;

public class MembershipPackage : BaseEntity
{
    public string PackageName { get; set; } = string.Empty;
    public decimal PackagePrice { get; set; }
    public string Description { get; set; } = string.Empty;
    // Navigation properties
    public ICollection<Membership> Memberships { get; set; } = new List<Membership>();
    public ICollection<MembershipPaymentHistory> PaymentHistory { get; set; } = new List<MembershipPaymentHistory>();
}
