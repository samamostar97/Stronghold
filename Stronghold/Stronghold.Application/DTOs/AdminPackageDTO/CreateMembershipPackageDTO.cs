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
        [StringLength(50, MinimumLength = 2, ErrorMessage = "Naziv paketa moze da sadrzi 2-50 karaktera")]
        public string PackageName { get; set; } = string.Empty;
        [Required]
        [Range(0.01,10000,ErrorMessage ="Paket ne moze biti skuplji od 10000")]
        public decimal PackagePrice { get; set; }
        [StringLength(255, MinimumLength = 2, ErrorMessage = "Opis paketa moze da sadrzi 2-255 karaktera")]
        public string Description { get; set; } = string.Empty;
        public bool IsActive { get; set; } = true;
    }
}
