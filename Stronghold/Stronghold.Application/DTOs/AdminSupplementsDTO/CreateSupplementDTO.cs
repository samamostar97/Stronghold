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
        [MaxLength(25,ErrorMessage ="Naziv je predug")]
        public string Name { get; set; } = string.Empty;
        [Required]
        [Range(0.01, double.MaxValue, ErrorMessage = "Cijena mora biti veća od 0")]
        public decimal Price { get; set; }
        public string? Description { get; set; }
        [Required]
        public int SupplementCategoryId { get; set; }
        [Required]
        public int SupplierId { get; set; }
    }
}
