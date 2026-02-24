namespace Stronghold.Application.Features.Memberships.DTOs;

public class MembershipPaymentResponse
{
    public int Id { get; set; }
    public int MembershipPackageId { get; set; }
    public string PackageName { get; set; } = string.Empty;
    public decimal AmountPaid { get; set; }
    public DateTime PaymentDate { get; set; }
    public DateTime StartDate { get; set; }
    public DateTime EndDate { get; set; }
}
