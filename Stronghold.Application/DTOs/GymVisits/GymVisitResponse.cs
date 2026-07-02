namespace Stronghold.Application.DTOs.GymVisits;

public class GymVisitResponse
{
    public int Id { get; set; }
    public int UserId { get; set; }
    public string UserFullName { get; set; } = null!;
    public string Username { get; set; } = null!;
    public DateTime CheckInAt { get; set; }
    public DateTime? CheckOutAt { get; set; }
    // Trajanje boravka u minutama; za korisnike jos u teretani racuna se do sada.
    public int DurationMinutes { get; set; }
}
