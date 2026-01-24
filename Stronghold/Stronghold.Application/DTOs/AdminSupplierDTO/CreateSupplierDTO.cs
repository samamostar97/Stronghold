using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Stronghold.Application.DTOs.AdminSupplierDTO
{
    public class CreateSupplierDTO
    {
        [Required]
        [StringLength(50, MinimumLength = 2, ErrorMessage = "Naziv dobavljaca moze da sadrzi 2-50 karaktera")]
        public string Name { get; set; } = string.Empty;
        [StringLength(50, MinimumLength = 2, ErrorMessage = "Web stranica moze da sadrzi 2-50 karaktera")]
        [RegularExpression(
         @"^(www\.)?([a-zA-Z0-9-]+\.)+[a-zA-Z]{2,}$",
         ErrorMessage = "Unesite ispravnu web adresu (npr. example.com ili www.example-site.com)")]
        public string? Website { get; set; }
    }
}
