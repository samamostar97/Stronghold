using System.ComponentModel.DataAnnotations;

namespace Stronghold.Application.DTOs.Cities;

public class CityUpsertRequest
{
    [Required(ErrorMessage = "Unesite naziv grada.")]
    [MaxLength(80, ErrorMessage = "Naziv grada može imati najviše 80 znakova.")]
    public string Name { get; set; } = null!;
}
