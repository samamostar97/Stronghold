namespace Stronghold.Core.Entities;

public class Address : BaseEntity
{
    public int UserId { get; set; }
    public string Street { get; set; } = string.Empty;
    public string City { get; set; } = string.Empty;
    public string PostalCode { get; set; } = string.Empty;
    public string Country { get; set; } = "Bosna i Hercegovina";

    // Navigation
    public User User { get; set; } = null!;
}
