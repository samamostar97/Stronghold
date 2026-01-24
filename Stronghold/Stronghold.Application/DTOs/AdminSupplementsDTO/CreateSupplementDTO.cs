using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Stronghold.Application.DTOs.AdminSupplementsDTO
{
    public class CreateSupplementDTO
    {
        [Required]
        [StringLength(50, MinimumLength = 2, ErrorMessage = "Naziv suplementa moze da sadrzi 2-50 karaktera")]
        public string Name { get; set; } = string.Empty;
        [Required]
        [Range(0.01, 10000, ErrorMessage = "Cijena mora biti veća od 0")]
        public decimal Price { get; set; }
        [StringLength(255, MinimumLength = 2, ErrorMessage = "Opis suplementa moze da sadrzi 2-255 karaktera")]
        public string? Description { get; set; }
        [Required]
        public int SupplementCategoryId { get; set; }
        [Required]
        public int SupplierId { get; set; }
    }
}
