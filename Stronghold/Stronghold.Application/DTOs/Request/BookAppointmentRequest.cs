using System.ComponentModel.DataAnnotations;
using Stronghold.Application.Common;

namespace Stronghold.Application.DTOs.Request
{
    public class BookAppointmentRequest : IValidatableObject
    {
        [Required(ErrorMessage = "Datum termina je obavezan.")]
        public DateTime Date { get; set; }

        public IEnumerable<ValidationResult> Validate(ValidationContext validationContext)
        {
            var localDate = StrongholdTimeUtils.ToLocal(Date);
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
}
