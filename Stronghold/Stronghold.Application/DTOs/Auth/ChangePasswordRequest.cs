using System.ComponentModel.DataAnnotations;

namespace Stronghold.Application.DTOs.Auth;

public class ChangePasswordRequest
{
    [Required]
    public string CurrentPassword { get; set; } = string.Empty;

    [Required]
    [MinLength(6, ErrorMessage = "Nova lozinka mora sadrzavati više od 6 karaktera")]
    public string NewPassword { get; set; } = string.Empty;
}
