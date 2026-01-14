namespace Stronghold.Application.DTOs.AdminMembershipsDTO;

public class MembershipPackageDTO
{
    public int Id { get; set; }
    public string PackageName { get; set; } = string.Empty;
    public decimal PackagePrice { get; set; }
    public string Description { get; set; } = string.Empty;
    public bool IsActive { get; set; }
}

public class CreateMembershipPackageRequest
{
    public string PackageName { get; set; } = string.Empty;
    public decimal PackagePrice { get; set; }
    public string Description { get; set; } = string.Empty;
}

public class UpdateMembershipPackageRequest
{
    public string PackageName { get; set; } = string.Empty;
    public decimal PackagePrice { get; set; }
    public string Description { get; set; } = string.Empty;
    public bool IsActive { get; set; }
}
