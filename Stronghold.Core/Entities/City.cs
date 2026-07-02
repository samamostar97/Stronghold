namespace Stronghold.Core.Entities;

public class City : BaseEntity
{
    public string Name { get; set; } = null!;

    public ICollection<User> Users { get; set; } = new List<User>();
    public ICollection<Order> Orders { get; set; } = new List<Order>();
}
