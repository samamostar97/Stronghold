namespace Stronghold.Application.DTOs.Payments;

public class PaymentResponse
{
    public int Id { get; set; }
    public int MembershipId { get; set; }
    public int UserId { get; set; }
    public string UserFullName { get; set; } = null!;
    public string PackageName { get; set; } = null!;
    public decimal Amount { get; set; }
    public DateTime PaidAt { get; set; }
}
