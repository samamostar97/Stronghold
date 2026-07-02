using System.ComponentModel.DataAnnotations;

namespace Stronghold.Application.DTOs.MembershipPackages;

public class MembershipPackageUpsertRequest
{
    [Required(ErrorMessage = "Unesite naziv paketa.")]
    [MaxLength(80, ErrorMessage = "Naziv paketa može imati najviše 80 znakova.")]
    public string Name { get; set; } = null!;

    [Range(0.01, 10000, ErrorMessage = "Cijena mora biti između 0.01 i 10000 KM.")]
    public decimal Price { get; set; }

    [Range(1, 3650, ErrorMessage = "Trajanje mora biti između 1 i 3650 dana.")]
    public int DurationDays { get; set; }

    [Required(ErrorMessage = "Unesite opis paketa.")]
    [MaxLength(500, ErrorMessage = "Opis može imati najviše 500 znakova.")]
    public string Description { get; set; } = null!;
}
