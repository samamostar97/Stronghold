using Stronghold.Domain.Enums;

namespace Stronghold.Domain.Entities;

public class Review : BaseEntity
{
    public int UserId { get; set; }
    public User User { get; set; } = null!;
    public string UserFullName { get; set; } = string.Empty;
    public int Rating { get; set; }
    public string? Comment { get; set; }
    public ReviewType ReviewType { get; set; }
    public int? ProductId { get; set; }
    public Product? Product { get; set; }
    public int? AppointmentId { get; set; }
    public Appointment? Appointment { get; set; }
}
