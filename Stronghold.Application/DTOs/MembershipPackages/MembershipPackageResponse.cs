namespace Stronghold.Application.DTOs.MembershipPackages;

public class MembershipPackageResponse
{
    public int Id { get; set; }
    public string Name { get; set; } = null!;
    public decimal Price { get; set; }
    public int DurationDays { get; set; }
    public string Description { get; set; } = null!;
}
