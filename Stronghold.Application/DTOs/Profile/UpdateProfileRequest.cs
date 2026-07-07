using System.ComponentModel.DataAnnotations;

namespace Stronghold.Application.DTOs.Profile;

public class UpdateProfileRequest
{
    [Required(ErrorMessage = "Unesite ime.")]
    [MaxLength(50, ErrorMessage = "Ime može imati najviše 50 znakova.")]
    public string FirstName { get; set; } = null!;

    [Required(ErrorMessage = "Unesite prezime.")]
    [MaxLength(50, ErrorMessage = "Prezime može imati najviše 50 znakova.")]
    public string LastName { get; set; } = null!;

    [Required(ErrorMessage = "Unesite e-mail adresu.")]
    [EmailAddress(ErrorMessage = "Unesite validnu e-mail adresu u formatu: ime@domena.com")]
    [MaxLength(100, ErrorMessage = "E-mail može imati najviše 100 znakova.")]
    public string Email { get; set; } = null!;

    [Required(ErrorMessage = "Unesite broj telefona.")]
    [RegularExpression(@"^0\d{2}-\d{3}-\d{3,4}$", ErrorMessage = "Unesite broj telefona u formatu: 061-123-456")]
    public string Phone { get; set; } = null!;

    [MaxLength(100, ErrorMessage = "Adresa može imati najviše 100 znakova.")]
    public string? StreetAddress { get; set; }

    public int? CityId { get; set; }

    public string? ImageBase64 { get; set; }
}
