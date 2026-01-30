using System.ComponentModel.DataAnnotations;

namespace Stronghold.Application.DTOs.UserDTOs
{
    public class CheckoutRequestDTO
    {
        [Required]
        [MinLength(1, ErrorMessage = "Korpa ne moze biti prazna.")]
        public List<CheckoutItemDTO> Items { get; set; } = new();
    }

    public class CheckoutItemDTO
    {
        public int SupplementId { get; set; }

        [Range(1, 99, ErrorMessage = "Kolicina mora biti izmedju 1 i 99.")]
        public int Quantity { get; set; }
    }
}
