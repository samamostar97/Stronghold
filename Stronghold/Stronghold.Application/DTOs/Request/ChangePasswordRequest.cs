using System.ComponentModel.DataAnnotations;

namespace Stronghold.Application.DTOs.Request
{
    public class ChangePasswordRequest
    {
        [Required(ErrorMessage = "Trenutna lozinka je obavezna.")]
        public string CurrentPassword { get; set; } = string.Empty;

        [Required(ErrorMessage = "Nova lozinka je obavezna.")]
        [MinLength(6, ErrorMessage = "Nova lozinka mora imati najmanje 6 karaktera.")]
        public string NewPassword { get; set; } = string.Empty;
    }
}
