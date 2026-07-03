using System.ComponentModel.DataAnnotations;

namespace Stronghold.Application.DTOs.Appointments;

public class AppointmentCancelRequest
{
    [Required(ErrorMessage = "Unesite razlog otkazivanja.")]
    [MaxLength(300, ErrorMessage = "Razlog može imati najviše 300 znakova.")]
    public string Reason { get; set; } = null!;
}
