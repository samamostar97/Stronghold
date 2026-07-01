namespace Stronghold.Core.Entities;

public class Seminar : BaseEntity
{
    public string Topic { get; set; } = null!;
    public string Speaker { get; set; } = null!;
    public DateTime ScheduledAt { get; set; }
    public int MaxCapacity { get; set; }

    public ICollection<SeminarRegistration> Registrations { get; set; } = new List<SeminarRegistration>();
}
