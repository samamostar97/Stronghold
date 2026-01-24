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
        [StringLength(50, MinimumLength = 2, ErrorMessage = "Naziv suplementa moze da sadrzi 2-50 karaktera")]
        public string? Name { get; set; }

        [Range(0.01, 10000, ErrorMessage = "Cijena mora biti veća od 0 , manja od 10000")]
        public decimal? Price { get; set; }
        [StringLength(255, MinimumLength = 2, ErrorMessage = "Opis suplementa moze da sadrzi 2-255 karaktera")]
        public string? Description { get; set; }
    }
}
