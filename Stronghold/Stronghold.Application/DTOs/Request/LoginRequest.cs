using System.ComponentModel.DataAnnotations;

namespace Stronghold.Application.DTOs.Request
{
    public class LoginRequest
    {
        [Required(ErrorMessage = "Korisničko ime je obavezno.")]
        [StringLength(50, ErrorMessage = "Korisničko ime može imati maksimalno 50 karaktera.")]
        public string Username { get; set; } = string.Empty;

        [Required(ErrorMessage = "Lozinka je obavezna.")]
        [StringLength(100, ErrorMessage = "Lozinka može imati maksimalno 100 karaktera.")]
        public string Password { get; set; } = string.Empty;
    }
}
