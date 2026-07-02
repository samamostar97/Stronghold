using System.ComponentModel.DataAnnotations;

namespace Stronghold.Application.DTOs.Auth;

public class RegisterRequest
{
    [Required(ErrorMessage = "Unesite ime.")]
    [MaxLength(50, ErrorMessage = "Ime može imati najviše 50 znakova.")]
    public string FirstName { get; set; } = null!;

    [Required(ErrorMessage = "Unesite prezime.")]
    [MaxLength(50, ErrorMessage = "Prezime može imati najviše 50 znakova.")]
    public string LastName { get; set; } = null!;

    [Required(ErrorMessage = "Unesite korisničko ime.")]
    [MinLength(3, ErrorMessage = "Korisničko ime mora imati najmanje 3 znaka.")]
    [MaxLength(50, ErrorMessage = "Korisničko ime može imati najviše 50 znakova.")]
    public string Username { get; set; } = null!;

    [Required(ErrorMessage = "Unesite e-mail adresu.")]
    [EmailAddress(ErrorMessage = "Unesite validnu e-mail adresu u formatu: ime@domena.com")]
    [MaxLength(100, ErrorMessage = "E-mail može imati najviše 100 znakova.")]
    public string Email { get; set; } = null!;

    [Required(ErrorMessage = "Unesite broj telefona.")]
    [RegularExpression(@"^[0-9+\-\/\s]{6,30}$", ErrorMessage = "Unesite validan broj telefona u formatu: 061-123-456")]
    public string Phone { get; set; } = null!;

    [Required(ErrorMessage = "Unesite lozinku.")]
    [MinLength(4, ErrorMessage = "Lozinka mora imati najmanje 4 znaka.")]
    public string Password { get; set; } = null!;
}
