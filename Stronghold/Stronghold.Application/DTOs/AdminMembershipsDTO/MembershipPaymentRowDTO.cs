namespace Stronghold.Application.DTOs.AdminMembershipsDTO;

public class MembershipPaymentRowDTO
{
    public int Id { get; set; }
    public int MembershipPackageId { get; set; }
    public string PackageName { get; set; } = string.Empty;
    public decimal AmountPaid { get; set; }
    public DateTime PaymentDate { get; set; }
    public DateTime StartDate { get; set; }
    public DateTime EndDate { get; set; }
}
