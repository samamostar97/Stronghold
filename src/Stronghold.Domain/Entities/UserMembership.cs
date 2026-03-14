namespace Stronghold.Domain.Entities;

public class UserMembership : BaseEntity
{
    public int UserId { get; set; }
    public User User { get; set; } = null!;
    public int MembershipPackageId { get; set; }
    public MembershipPackage MembershipPackage { get; set; } = null!;
    public string UserFullName { get; set; } = string.Empty;
    public string PackageName { get; set; } = string.Empty;
    public decimal PackagePrice { get; set; }
    public DateTime StartDate { get; set; }
    public DateTime EndDate { get; set; }
    public bool IsActive { get; set; }
}
