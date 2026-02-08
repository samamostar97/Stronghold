using System.ComponentModel.DataAnnotations;

namespace Stronghold.Application.DTOs.Request
{
    public class CreateSupplementRequest
    {
        [Required(ErrorMessage = "Naziv je obavezan.")]
        [StringLength(100, MinimumLength = 2, ErrorMessage = "Naziv suplementa mora imati između 2 i 100 karaktera.")]
        public string Name { get; set; } = string.Empty;

        [Required(ErrorMessage = "Cijena je obavezna.")]
        [Range(0.01, 10000, ErrorMessage = "Cijena mora biti veća od 0 i manja ili jednaka 10000.")]
        public decimal Price { get; set; }

        [StringLength(1000, MinimumLength = 2, ErrorMessage = "Opis suplementa mora imati između 2 i 1000 karaktera.")]
        public string? Description { get; set; }

        [Range(1, int.MaxValue, ErrorMessage = "Kategorija suplementa je obavezna.")]
        public int SupplementCategoryId { get; set; }

        [Range(1, int.MaxValue, ErrorMessage = "Dobavljač je obavezan.")]
        public int SupplierId { get; set; }
    }
}
