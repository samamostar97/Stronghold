using System.ComponentModel.DataAnnotations;

namespace Stronghold.Application.DTOs.SupplementCategories;

public class SupplementCategoryUpsertRequest
{
    [Required(ErrorMessage = "Unesite naziv kategorije.")]
    [MaxLength(80, ErrorMessage = "Naziv kategorije može imati najviše 80 znakova.")]
    public string Name { get; set; } = null!;

    [Required(ErrorMessage = "Unesite opis kategorije.")]
    [MaxLength(500, ErrorMessage = "Opis može imati najviše 500 znakova.")]
    public string Description { get; set; } = null!;
}
