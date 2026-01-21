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
        [MaxLength(25, ErrorMessage = "Naziv je predug")]
        public string? Name { get; set; }

        [Range(0.01, double.MaxValue, ErrorMessage = "Cijena mora biti veća od 0")]
        public decimal? Price { get; set; }

        public string? Description { get; set; }
    }
}
