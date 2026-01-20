namespace Stronghold.Core.Entities;

public class Nutritionist : BaseEntity
{
    public string FirstName { get; set; } = string.Empty;
    public string LastName { get; set; } = string.Empty;
    public string Email { get; set; } = string.Empty;
    public string PhoneNumber { get; set; } = string.Empty;

    // Navigation property
    public ICollection<Appointment> Appointments { get; set; } = new List<Appointment>();
}
