using System.ComponentModel.DataAnnotations;

namespace Stronghold.Application.DTOs.Request
{
    public class UpdateMembershipPackageRequest
    {
        [StringLength(50, MinimumLength = 2, ErrorMessage = "Naziv paketa mora imati između 2 i 50 karaktera.")]
        public string? PackageName { get; set; }

        [Range(0.01, 10000, ErrorMessage = "Cijena mora biti veća od 0 i manja ili jednaka 10000.")]
        public decimal? PackagePrice { get; set; }

        [StringLength(500, ErrorMessage = "Opis paketa može imati najviše 500 karaktera.")]
        public string? Description { get; set; }

        public bool? IsActive { get; set; }
    }
}
