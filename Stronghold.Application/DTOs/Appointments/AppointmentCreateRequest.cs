using System.ComponentModel.DataAnnotations;

namespace Stronghold.Application.DTOs.Appointments;

/// <summary>Mobile booking - korisnik dolazi iz JWT tokena, ne iz body-ja.</summary>
public class AppointmentCreateRequest
{
    [Range(1, int.MaxValue, ErrorMessage = "Odaberite trenera ili nutricionistu.")]
    public int StaffMemberId { get; set; }

    public DateOnly Date { get; set; }

    [Range(0, 23, ErrorMessage = "Satnica mora biti između 0 i 23.")]
    public int StartHour { get; set; }
}
