namespace Stronghold.Domain.Entities;

public class SeminarRegistration : BaseEntity
{
    public int SeminarId { get; set; }
    public Seminar Seminar { get; set; } = null!;
    public int UserId { get; set; }
    public User User { get; set; } = null!;
}
