using System.ComponentModel.DataAnnotations;

namespace Stronghold.Application.DTOs.Request
{
    public class AssignMembershipRequest : IValidatableObject
    {
        [Range(1, int.MaxValue, ErrorMessage = "Korisnik je obavezan.")]
        public int UserId { get; set; }

        [Range(1, int.MaxValue, ErrorMessage = "Paket članarine je obavezan.")]
        public int MembershipPackageId { get; set; }

        [Range(0.01, 10000, ErrorMessage = "Iznos mora biti veći od 0 i manji ili jednak 10000.")]
        public decimal AmountPaid { get; set; }

        [Required(ErrorMessage = "Datum početka je obavezan.")]
        public DateTime StartDate { get; set; }

        [Required(ErrorMessage = "Datum završetka je obavezan.")]
        public DateTime EndDate { get; set; }

        [Required(ErrorMessage = "Datum uplate je obavezan.")]
        public DateTime PaymentDate { get; set; }

        public IEnumerable<ValidationResult> Validate(ValidationContext validationContext)
        {
            if (EndDate.Date < StartDate.Date)
            {
                yield return new ValidationResult("EndDate ne moze biti prije StartDate-a");
            }

            if (PaymentDate.Date < StartDate.Date || PaymentDate.Date > EndDate.Date)
            {
                yield return new ValidationResult("PaymentDate mora biti unutar perioda clanarine.");
            }
        }
    }
}
