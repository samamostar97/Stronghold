using System.ComponentModel.DataAnnotations;

namespace Stronghold.Application.DTOs.Seminars;

public class SeminarCancelRequest
{
    [Required(ErrorMessage = "Unesite razlog otkazivanja.")]
    [MaxLength(300, ErrorMessage = "Razlog može imati najviše 300 znakova.")]
    public string Reason { get; set; } = null!;
}
