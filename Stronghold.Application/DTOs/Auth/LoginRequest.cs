using System.ComponentModel.DataAnnotations;

namespace Stronghold.Application.DTOs.Auth;

public class LoginRequest
{
    [Required(ErrorMessage = "Unesite korisničko ime ili e-mail.")]
    public string UsernameOrEmail { get; set; } = null!;

    [Required(ErrorMessage = "Unesite lozinku.")]
    public string Password { get; set; } = null!;
}
