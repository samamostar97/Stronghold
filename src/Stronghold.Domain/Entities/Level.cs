namespace Stronghold.Domain.Entities;

public class Level : BaseEntity
{
    public string Name { get; set; } = string.Empty;
    public int MinXP { get; set; }
    public int MaxXP { get; set; }
    public string? BadgeImageUrl { get; set; }
}
