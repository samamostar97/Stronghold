using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Stronghold.Application.DTOs.AdminSupplierDTO
{
    public class UpdateSupplierDTO
    {
        [MinLength(2,ErrorMessage ="Naziv prekratak")]
        public string? Name { get; set; }
        public string? Website { get; set; }
    }
}
