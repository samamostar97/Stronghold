using System.ComponentModel.DataAnnotations;

namespace Stronghold.Application.DTOs.Request
{
    public class CheckoutRequest : IValidatableObject
    {
        [Required]
        [MinLength(1, ErrorMessage = "Korpa ne moze biti prazna.")]
        public List<CheckoutItemRequest> Items { get; set; } = new();

        public IEnumerable<ValidationResult> Validate(ValidationContext validationContext)
        {
            if (Items == null || Items.Count == 0)
            {
                yield break;
            }

            var hasDuplicates = Items
                .Select(x => x.SupplementId)
                .Distinct()
                .Count() != Items.Count;

            if (hasDuplicates)
            {
                yield return new ValidationResult("Duplicirane stavke nisu dozvoljene.");
            }
        }
    }

    public class CheckoutItemRequest
    {
        [Range(1, int.MaxValue, ErrorMessage = "Suplement je obavezan.")]
        public int SupplementId { get; set; }

        [Range(1, 99, ErrorMessage = "Kolicina mora biti izmedju 1 i 99.")]
        public int Quantity { get; set; }
    }
}
