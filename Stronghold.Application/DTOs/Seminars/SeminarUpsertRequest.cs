using System.ComponentModel.DataAnnotations;

namespace Stronghold.Application.DTOs.Seminars;

public class SeminarUpsertRequest
{
    [Required(ErrorMessage = "Unesite temu seminara.")]
    [MaxLength(150, ErrorMessage = "Tema može imati najviše 150 znakova.")]
    public string Topic { get; set; } = null!;

    [Required(ErrorMessage = "Unesite ime predavača.")]
    [MaxLength(100, ErrorMessage = "Ime predavača može imati najviše 100 znakova.")]
    public string Speaker { get; set; } = null!;

    public DateTime ScheduledAt { get; set; }

    [Range(1, 1000, ErrorMessage = "Kapacitet mora biti između 1 i 1000.")]
    public int MaxCapacity { get; set; }
}
