using System.ComponentModel.DataAnnotations;

namespace Stronghold.Application.DTOs.Request
{
    public class ResetPasswordRequest
    {
        [Required(ErrorMessage = "Email je obavezan.")]
        [EmailAddress(ErrorMessage = "Email nije validan.")]
        [StringLength(255, MinimumLength = 5, ErrorMessage = "Email mora imati izmedju 5 i 255 karaktera.")]
        public string Email { get; set; } = string.Empty;

        [Required(ErrorMessage = "Kod je obavezan.")]
        [RegularExpression(@"^\d{6}$", ErrorMessage = "Kod mora imati tacno 6 cifara.")]
        public string Code { get; set; } = string.Empty;

        [Required(ErrorMessage = "Nova lozinka je obavezna.")]
        [StringLength(100, MinimumLength = 6, ErrorMessage = "Nova lozinka mora imati izmedju 6 i 100 karaktera.")]
        public string NewPassword { get; set; } = string.Empty;
    }
}
