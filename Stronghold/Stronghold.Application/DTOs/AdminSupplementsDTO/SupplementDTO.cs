using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Stronghold.Application.DTOs.AdminSupplementsDTO
{
    public class SupplementDTO
    {
        public int Id { get; set; }
        public string Name { get; set; } = string.Empty;
        public decimal Price { get; set; }
        public string? Description { get; set; }

        public int SupplementCategoryId { get; set; }
        public string SupplementCategoryName { get; set; } = string.Empty;
        public int SupplierId { get; set; }
        public string SupplierName { get; set; }= string.Empty;
        public string? SupplementImageUrl { get; set; }

    }
}
