using Stronghold.Core.Enums;

namespace Stronghold.Core.Entities;

/// <summary>
/// Jedna tabela za trenere i nutricioniste (StaffType).
/// Radno vrijeme (WorkStartHour/WorkEndHour) je osnova za slobodne satnice termina.
/// </summary>
public class StaffMember : BaseEntity
{
    public string FirstName { get; set; } = null!;
    public string LastName { get; set; } = null!;
    public StaffType StaffType { get; set; }
    public byte[]? ImageData { get; set; }
    public string Biography { get; set; } = null!;
    public string Email { get; set; } = null!;
    public string Phone { get; set; } = null!;
    public int WorkStartHour { get; set; }
    public int WorkEndHour { get; set; }

    public ICollection<Appointment> Appointments { get; set; } = new List<Appointment>();
}
