using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

using System.ComponentModel.DataAnnotations;

namespace Stronghold.Application.DTOs.AdminSupplementsDTO
{
    public class UpdateSupplementDTO
    {
        [StringLength(100, MinimumLength = 2, ErrorMessage = "Naziv suplementa mora imati između 2 i 100 karaktera.")]
        public string? Name { get; set; }

        [Range(0.01, 10000, ErrorMessage = "Cijena mora biti veća od 0 i manja ili jednaka 10000.")]
        public decimal? Price { get; set; }

        [StringLength(1000, MinimumLength = 2, ErrorMessage = "Opis suplementa mora imati između 2 i 1000 karaktera.")]
        public string? Description { get; set; }
    }
}
