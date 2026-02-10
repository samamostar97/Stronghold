using System.ComponentModel.DataAnnotations;

namespace Stronghold.Application.DTOs.Request;

public class AdminCreateAppointmentRequest : IValidatableObject
{
    [Required(ErrorMessage = "Korisnik je obavezan.")]
    public int UserId { get; set; }

    public int? TrainerId { get; set; }
    public int? NutritionistId { get; set; }

    [Required(ErrorMessage = "Datum termina je obavezan.")]
    public DateTime AppointmentDate { get; set; }

    public IEnumerable<ValidationResult> Validate(ValidationContext validationContext)
    {
        if (TrainerId == null && NutritionistId == null)
            yield return new ValidationResult("Morate odabrati trenera ili nutricionistu.");

        if (TrainerId != null && NutritionistId != null)
            yield return new ValidationResult("Termin moze biti samo kod trenera ili nutricioniste, ne oba.");

        if (AppointmentDate <= DateTime.UtcNow)
            yield return new ValidationResult("Datum termina mora biti u buducnosti.");
    }
}
