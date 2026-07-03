using System.ComponentModel.DataAnnotations;

namespace Stronghold.Application.DTOs.Appointments;

/// <summary>Desktop - admin direktno dodaje termin za odabranog clana.</summary>
public class AdminAppointmentCreateRequest
{
    [Range(1, int.MaxValue, ErrorMessage = "Odaberite korisnika.")]
    public int UserId { get; set; }

    [Range(1, int.MaxValue, ErrorMessage = "Odaberite trenera ili nutricionistu.")]
    public int StaffMemberId { get; set; }

    public DateOnly Date { get; set; }

    [Range(0, 23, ErrorMessage = "Satnica mora biti između 0 i 23.")]
    public int StartHour { get; set; }
}
