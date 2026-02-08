using System.ComponentModel.DataAnnotations;

namespace Stronghold.Application.DTOs.Request
{
    public class CheckoutRequest
    {
        [Required]
        [MinLength(1, ErrorMessage = "Korpa ne može biti prazna.")]
        public List<CheckoutItemRequest> Items { get; set; } = new();
    }

    public class CheckoutItemRequest
    {
        public int SupplementId { get; set; }

        [Range(1, 99, ErrorMessage = "Količina mora biti između 1 i 99.")]
        public int Quantity { get; set; }
    }
}
