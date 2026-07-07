using System.ComponentModel.DataAnnotations;
using Stronghold.Core.Enums;

namespace Stronghold.Application.DTOs.StaffMembers;

public class StaffMemberUpsertRequest : IValidatableObject
{
    [Required(ErrorMessage = "Unesite ime.")]
    [MaxLength(50, ErrorMessage = "Ime može imati najviše 50 znakova.")]
    public string FirstName { get; set; } = null!;

    [Required(ErrorMessage = "Unesite prezime.")]
    [MaxLength(50, ErrorMessage = "Prezime može imati najviše 50 znakova.")]
    public string LastName { get; set; } = null!;

    public StaffType StaffType { get; set; }

    [Required(ErrorMessage = "Unesite biografiju.")]
    [MaxLength(2000, ErrorMessage = "Biografija može imati najviše 2000 znakova.")]
    public string Biography { get; set; } = null!;

    [Required(ErrorMessage = "Unesite e-mail adresu.")]
    [EmailAddress(ErrorMessage = "Unesite validnu e-mail adresu u formatu: ime@domena.com")]
    [MaxLength(100, ErrorMessage = "E-mail može imati najviše 100 znakova.")]
    public string Email { get; set; } = null!;

    [Required(ErrorMessage = "Unesite broj telefona.")]
    [RegularExpression(@"^0\d{2}-\d{3}-\d{3,4}$", ErrorMessage = "Unesite broj telefona u formatu: 061-123-456")]
    public string Phone { get; set; } = null!;

    [Range(0, 23, ErrorMessage = "Početak radnog vremena mora biti između 0 i 23.")]
    public int WorkStartHour { get; set; }

    [Range(1, 24, ErrorMessage = "Kraj radnog vremena mora biti između 1 i 24.")]
    public int WorkEndHour { get; set; }

    public string? ImageBase64 { get; set; }

    public IEnumerable<ValidationResult> Validate(ValidationContext validationContext)
    {
        if (WorkEndHour <= WorkStartHour)
        {
            yield return new ValidationResult(
                "Kraj radnog vremena mora biti nakon početka.",
                new[] { nameof(WorkEndHour) });
        }
    }
}
