namespace Stronghold.Core.Entities;

public class Supplier : BaseEntity
{
    public string Name { get; set; } = null!;
    public string ContactEmail { get; set; } = null!;
    public string ContactPhone { get; set; } = null!;

    public ICollection<Supplement> Supplements { get; set; } = new List<Supplement>();
}
