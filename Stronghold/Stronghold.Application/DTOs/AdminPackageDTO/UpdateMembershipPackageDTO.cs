using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Stronghold.Application.DTOs.AdminPackageDTO
{
    public class UpdateMembershipPackageDTO
    {
        [StringLength(50, MinimumLength = 2, ErrorMessage = "Naziv paketa moze da sadrzi 2-50 karaktera")]
        public string? PackageName { get; set; }
        [Range(0.01, 10000, ErrorMessage = "Cijena paketa mora da bude veca od 0 manja od 10000")]
        public decimal? PackagePrice { get; set; }
        [StringLength(255, MinimumLength = 2, ErrorMessage = "Opis paketa moze da sadrzi 2-255 karaktera")]
        public string? Description { get; set; } 
        public bool? IsActive { get; set; } 
    }
}
