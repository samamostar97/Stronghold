using System.ComponentModel.DataAnnotations;

namespace Stronghold.Application.DTOs.Request
{
    public class ResetPasswordRequest
    {
        [Required(ErrorMessage = "Email je obavezan.")]
        [EmailAddress(ErrorMessage = "Email nije validan.")]
        public string Email { get; set; } = string.Empty;

        [Required(ErrorMessage = "Kod je obavezan.")]
        public string Code { get; set; } = string.Empty;

        [Required(ErrorMessage = "Nova lozinka je obavezna.")]
        [MinLength(6, ErrorMessage = "Nova lozinka mora imati najmanje 6 karaktera.")]
        public string NewPassword { get; set; } = string.Empty;
    }
}
