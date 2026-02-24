using System.ComponentModel.DataAnnotations;

namespace Stronghold.Application.Features.Auth.DTOs
{
    public class ChangePasswordRequest : IValidatableObject
    {
        [Required(ErrorMessage = "Trenutna lozinka je obavezna.")]
        [StringLength(100, ErrorMessage = "Trenutna lozinka moze imati maksimalno 100 karaktera.")]
        public string CurrentPassword { get; set; } = string.Empty;

        [Required(ErrorMessage = "Nova lozinka je obavezna.")]
        [StringLength(100, MinimumLength = 6, ErrorMessage = "Nova lozinka mora imati izmedju 6 i 100 karaktera.")]
        public string NewPassword { get; set; } = string.Empty;

        public IEnumerable<ValidationResult> Validate(ValidationContext validationContext)
        {
            if (!string.IsNullOrWhiteSpace(CurrentPassword) &&
                !string.IsNullOrWhiteSpace(NewPassword) &&
                CurrentPassword == NewPassword)
            {
                yield return new ValidationResult("Nova lozinka mora biti razlicita od trenutne.");
            }
        }
    }
}
