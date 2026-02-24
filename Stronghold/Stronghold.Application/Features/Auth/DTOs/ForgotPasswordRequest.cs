using System.ComponentModel.DataAnnotations;

namespace Stronghold.Application.Features.Auth.DTOs
{
    public class ForgotPasswordRequest
    {
        [Required(ErrorMessage = "Email je obavezan.")]
        [EmailAddress(ErrorMessage = "Email nije validan.")]
        [StringLength(255, MinimumLength = 5, ErrorMessage = "Email mora imati izmedju 5 i 255 karaktera.")]
        public string Email { get; set; } = string.Empty;
    }
}
