namespace Stronghold.Domain.Entities;

public class Seminar : BaseEntity
{
    public string Name { get; set; } = string.Empty;
    public string Description { get; set; } = string.Empty;
    public string Lecturer { get; set; } = string.Empty;
    public DateTime StartDate { get; set; }
    public int DurationMinutes { get; set; } = 120;
    public int MaxCapacity { get; set; }

    public ICollection<SeminarRegistration> Registrations { get; set; } = new List<SeminarRegistration>();
}
