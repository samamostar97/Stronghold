using System.ComponentModel.DataAnnotations;

namespace Stronghold.Application.DTOs.Auth;

public class ResetPasswordRequest
{
    [Required(ErrorMessage = "Unesite e-mail adresu.")]
    [EmailAddress(ErrorMessage = "Unesite validnu e-mail adresu u formatu: ime@domena.com")]
    public string Email { get; set; } = null!;

    [Required(ErrorMessage = "Unesite kod iz e-maila.")]
    [StringLength(6, MinimumLength = 6, ErrorMessage = "Kod ima tačno 6 cifara.")]
    public string Code { get; set; } = null!;

    [Required(ErrorMessage = "Unesite novu lozinku.")]
    [MinLength(4, ErrorMessage = "Nova lozinka mora imati najmanje 4 znaka.")]
    public string NewPassword { get; set; } = null!;
}
