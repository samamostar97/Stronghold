namespace Stronghold.Application.DTOs.AdminMembershipsDTO;

public class AddMembershipPaymentRequest
{
    public int MembershipPackageId { get; set; }
    public DateTime StartDate { get; set; }
    public DateTime EndDate { get; set; }
    public decimal AmountPaid { get; set; }
    public DateTime PaymentDate { get; set; } = DateTime.UtcNow;
}
