using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Stronghold.Application.DTOs.AdminReportsDTO
{
    public class BestSellerDTO
    {
        public int SupplementId { get; set; }
        public string Name { get; set; } = string.Empty;
        public int QuantitySold { get; set; }
    }
}
