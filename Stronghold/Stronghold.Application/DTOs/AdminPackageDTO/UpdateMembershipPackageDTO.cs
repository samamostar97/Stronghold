using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Stronghold.Application.DTOs.AdminPackageDTO
{
    public class UpdateMembershipPackageDTO
    {
        public string? PackageName { get; set; } 
        public decimal? PackagePrice { get; set; }
        public string? Description { get; set; } 
        public bool? IsActive { get; set; } 
    }
}
