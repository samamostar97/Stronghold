namespace Stronghold.Core.Entities;

public class MembershipPayment : BaseEntity
{
    public int UserId { get; set; }
    public int MembershipPackageId { get; set; }
    public decimal Amount { get; set; }
    public DateTime PaymentDate { get; set; }

    // Navigation properties
    public User User { get; set; } = null!;
    public MembershipPackage MembershipPackage { get; set; } = null!;
}
