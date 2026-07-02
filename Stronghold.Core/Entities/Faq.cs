namespace Stronghold.Core.Entities;

public class Faq : BaseEntity
{
    public string Question { get; set; } = null!;
    public string Answer { get; set; } = null!;
}
