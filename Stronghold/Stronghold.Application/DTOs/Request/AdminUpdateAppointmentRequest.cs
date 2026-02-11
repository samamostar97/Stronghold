using System.ComponentModel.DataAnnotations;
using Stronghold.Application.Common;

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

        var localDate = StrongholdTimeUtils.ToLocal(AppointmentDate);
        var localNow = StrongholdTimeUtils.LocalNow;

        if (localDate < localNow)
            yield return new ValidationResult("Nemoguce unijeti datum u proslosti");

        if (localDate.Date == StrongholdTimeUtils.LocalToday)
            yield return new ValidationResult("Nemoguce napraviti termin na isti dan");

        if (localDate.Hour < 9 || localDate.Hour >= 17)
            yield return new ValidationResult("Termini su moguci samo izmedju 9:00 i 17:00.");

        if (localDate.Minute != 0 || localDate.Second != 0 || localDate.Millisecond != 0)
            yield return new ValidationResult("Termin mora biti unesen na puni sat.");
    }
}
