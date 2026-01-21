using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Stronghold.Application.DTOs.AdminPackageDTO
{
    public class CreateMembershipPackageDTO
    {
        [Required]
        [MaxLength(50,ErrorMessage ="Naziv predug")]
        public string PackageName { get; set; } = string.Empty;
        [Required]
        [Range(0.01,10000,ErrorMessage ="Paket ne moze biti skuplji od 10000")]
        public decimal PackagePrice { get; set; }
        public string Description { get; set; } = string.Empty;
        public bool IsActive { get; set; } = true;
    }
}
