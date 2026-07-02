namespace Stronghold.Core.Entities;

public class SupplementCategory : BaseEntity
{
    public string Name { get; set; } = null!;
    public string Description { get; set; } = null!;

    public ICollection<Supplement> Supplements { get; set; } = new List<Supplement>();
}
