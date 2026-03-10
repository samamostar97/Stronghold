namespace Stronghold.Application.Features.UserMemberships;

public class UserMembershipResponse
{
    public int Id { get; set; }
    public int UserId { get; set; }
    public string UserFullName { get; set; } = string.Empty;
    public int MembershipPackageId { get; set; }
    public string MembershipPackageName { get; set; } = string.Empty;
    public decimal MembershipPackagePrice { get; set; }
    public DateTime StartDate { get; set; }
    public DateTime EndDate { get; set; }
    public bool IsActive { get; set; }
    public DateTime CreatedAt { get; set; }
}
