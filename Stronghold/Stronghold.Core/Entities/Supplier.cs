namespace Stronghold.Core.Entities;

public class Supplier : BaseEntity
{
    public string Name { get; set; } = string.Empty;
    public string? Website { get; set; }

    // Navigation property
    public ICollection<Supplement> Supplements { get; set; } = new List<Supplement>();
}
