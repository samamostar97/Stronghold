using System.ComponentModel.DataAnnotations;

namespace Stronghold.Application.DTOs.Reviews;

public class ReviewCreateRequest
{
    [Range(1, int.MaxValue, ErrorMessage = "Odaberite suplement.")]
    public int SupplementId { get; set; }

    [Range(1, 5, ErrorMessage = "Ocjena mora biti između 1 i 5.")]
    public int Rating { get; set; }

    [MaxLength(1000, ErrorMessage = "Komentar može imati najviše 1000 znakova.")]
    public string? Comment { get; set; }
}
