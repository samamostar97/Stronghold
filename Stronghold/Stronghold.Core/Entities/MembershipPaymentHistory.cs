namespace Stronghold.Core.Entities;

public class MembershipPaymentHistory : BaseEntity
{
    public int UserId { get; set; }
    public int MembershipPackageId { get; set; }
    public decimal AmountPaid { get; set; }
    public DateTime PaymentDate { get; set; }
    public DateTime StartDate { get; set; }
    public DateTime EndDate { get; set; }

    // Navigation properties
    public User User { get; set; } = null!;
    public MembershipPackage MembershipPackage { get; set; } = null!;
}
