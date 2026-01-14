namespace Stronghold.Application.DTOs.AdminMembershipsDTO;

public class UserMembershipDTO
{
    public int? MembershipId { get; set; }
    public int? MembershipPackageId { get; set; }
    public string? PackageName { get; set; }
    public DateTime? StartDate { get; set; }
    public DateTime? EndDate { get; set; }
    public bool IsActive => EndDate.HasValue && EndDate.Value >= DateTime.UtcNow;
}
