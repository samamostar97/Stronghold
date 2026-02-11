using System.ComponentModel.DataAnnotations;

namespace Stronghold.Application.DTOs.Request
{
    public class ConfirmOrderRequest : IValidatableObject
    {
        [Required(ErrorMessage = "PaymentIntentId je obavezan.")]
        public string PaymentIntentId { get; set; } = string.Empty;

        [Required]
        [MinLength(1, ErrorMessage = "Stavke narudzbe su obavezne.")]
        public List<CheckoutItemRequest> Items { get; set; } = new();

        public IEnumerable<ValidationResult> Validate(ValidationContext validationContext)
        {
            if (string.IsNullOrWhiteSpace(PaymentIntentId))
            {
                yield return new ValidationResult("PaymentIntentId je obavezan.", new[] { nameof(PaymentIntentId) });
            }

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
}
