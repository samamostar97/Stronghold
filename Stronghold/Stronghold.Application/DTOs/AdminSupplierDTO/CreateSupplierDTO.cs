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
        [MinLength(2,ErrorMessage ="Naziv je prekratak")]
        public string Name { get; set; } = string.Empty;
        public string? Website { get; set; }
    }
}
