using System.ComponentModel.DataAnnotations;

namespace Stronghold.Application.DTOs.Auth;

public class ResetPasswordRequest
{
    [Required]
    [EmailAddress]
    public string Email { get; set; } = string.Empty;

    [Required]
    [StringLength(6, MinimumLength = 6)]
    public string Code { get; set; } = string.Empty;

    [Required]
    [MinLength(6, ErrorMessage = "Nova lozinka mora sadrzavati više od 6 karaktera")]
    public string NewPassword { get; set; } = string.Empty;
}
