namespace Stronghold.Application.Features.MembershipPackages.DTOs;

public class MembershipPackageResponse
{
    public int Id { get; set; }

public string PackageName { get; set; } = string.Empty;
    public decimal PackagePrice { get; set; }

public string Description { get; set; } = string.Empty;
    public DateTime CreatedAt { get; set; }
}
