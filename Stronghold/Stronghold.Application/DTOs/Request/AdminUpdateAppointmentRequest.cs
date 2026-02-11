using System.ComponentModel.DataAnnotations;

namespace Stronghold.Application.DTOs.Request;

public class AdminUpdateAppointmentRequest : IValidatableObject
{
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

        var localDate = AppointmentDate.Kind == DateTimeKind.Utc ? AppointmentDate.ToLocalTime() : AppointmentDate;

        if (localDate < DateTime.Now)
            yield return new ValidationResult("Nemoguce unijeti datum u proslosti");

        if (localDate.Date == DateTime.Today)
            yield return new ValidationResult("Nemoguce napraviti termin na isti dan");

        if (localDate.Hour < 9 || localDate.Hour >= 17)
            yield return new ValidationResult("Termini su moguci samo izmedju 9:00 i 17:00.");

        if (localDate.Minute != 0 || localDate.Second != 0 || localDate.Millisecond != 0)
            yield return new ValidationResult("Termin mora biti unesen na puni sat.");
    }
}
