using System.ComponentModel.DataAnnotations;

namespace Stronghold.Application.DTOs.UserDTOs
{
    public class ConfirmOrderDTO
    {
        [Required(ErrorMessage = "PaymentIntentId je obavezan.")]
        public string PaymentIntentId { get; set; } = string.Empty;

        [Required]
        [MinLength(1, ErrorMessage = "Stavke narudzbe su obavezne.")]
        public List<CheckoutItemDTO> Items { get; set; } = new();
    }
}
