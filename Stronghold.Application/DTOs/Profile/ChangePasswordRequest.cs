using System.ComponentModel.DataAnnotations;

namespace Stronghold.Application.DTOs.Profile;

// Korisnik koji mijenja SVOJU lozinku mora potvrditi staru.
public class ChangePasswordRequest
{
    [Required(ErrorMessage = "Unesite trenutnu lozinku.")]
    public string OldPassword { get; set; } = null!;

    [Required(ErrorMessage = "Unesite novu lozinku.")]
    [MinLength(4, ErrorMessage = "Nova lozinka mora imati najmanje 4 znaka.")]
    public string NewPassword { get; set; } = null!;
}
