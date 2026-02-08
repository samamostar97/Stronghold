using System.ComponentModel.DataAnnotations;

namespace Stronghold.Application.DTOs.Request
{
    public class ConfirmOrderRequest
    {
        [Required(ErrorMessage = "PaymentIntentId je obavezan.")]
        public string PaymentIntentId { get; set; } = string.Empty;

        [Required]
        [MinLength(1, ErrorMessage = "Stavke narudžbe su obavezne.")]
        public List<CheckoutItemRequest> Items { get; set; } = new();
    }
}
