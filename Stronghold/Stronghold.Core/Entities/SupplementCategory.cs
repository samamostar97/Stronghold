namespace Stronghold.Core.Entities;

public class SupplementCategory : BaseEntity
{
    public string Name { get; set; } = string.Empty;

    // Navigation property
    public ICollection<Supplement> Supplements { get; set; } = new List<Supplement>();
}
