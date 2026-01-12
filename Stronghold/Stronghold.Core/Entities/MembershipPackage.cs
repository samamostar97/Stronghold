namespace Stronghold.Core.Entities;

public class MembershipPackage : BaseEntity
{
    public string Name { get; set; } = string.Empty;
    public decimal Price { get; set; }
    public string? Description { get; set; }
    public DateTime StartDate { get; set; }
    public DateTime EndDate { get; set; }

    public int UserId { get; set; }

    // Navigation property
    public User User { get; set; } = null!;
}
