using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Stronghold.Application.DTOs.AdminSuppliersDTO
{
    public class CreateSupplierDTO
    {
        public string Name { get; set; } = string.Empty;
        public string? Website { get; set; }
    }
}
