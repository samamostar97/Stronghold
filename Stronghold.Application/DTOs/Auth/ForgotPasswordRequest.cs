using System.ComponentModel.DataAnnotations;

namespace Stronghold.Application.DTOs.Auth;

public class ForgotPasswordRequest
{
    [Required(ErrorMessage = "Unesite e-mail adresu.")]
    [EmailAddress(ErrorMessage = "Unesite validnu e-mail adresu u formatu: ime@domena.com")]
    public string Email { get; set; } = null!;
}
