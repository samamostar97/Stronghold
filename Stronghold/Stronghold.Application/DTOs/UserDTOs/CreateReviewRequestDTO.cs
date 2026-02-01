using System.ComponentModel.DataAnnotations;

namespace Stronghold.Application.DTOs.UserDTOs;

public class CreateReviewRequestDTO
{
    [Range(1, int.MaxValue, ErrorMessage = "Suplement je obavezan.")]
    public int SupplementId { get; set; }

    [Range(1, 5, ErrorMessage = "Ocjena mora biti izme?u 1 i 5.")]
    public int Rating { get; set; }

    [StringLength(1000, MinimumLength = 2, ErrorMessage = "Komentar mora imati izme?u 2 i 1000 karaktera.")]
    public string? Comment { get; set; }
}
