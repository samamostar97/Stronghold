using System.ComponentModel.DataAnnotations;

namespace Stronghold.Application.DTOs.Supplements;

public class SupplementUpsertRequest
{
    [Required(ErrorMessage = "Unesite naziv suplementa.")]
    [MaxLength(120, ErrorMessage = "Naziv može imati najviše 120 znakova.")]
    public string Name { get; set; } = null!;

    [Range(0.01, 100000, ErrorMessage = "Cijena mora biti između 0.01 i 100000 KM.")]
    public decimal Price { get; set; }

    [Required(ErrorMessage = "Unesite opis suplementa.")]
    [MaxLength(1000, ErrorMessage = "Opis može imati najviše 1000 znakova.")]
    public string Description { get; set; } = null!;

    [Range(1, int.MaxValue, ErrorMessage = "Odaberite kategoriju.")]
    public int CategoryId { get; set; }

    [Range(1, int.MaxValue, ErrorMessage = "Odaberite dobavljača.")]
    public int SupplierId { get; set; }

    [Range(0, 100000, ErrorMessage = "Stanje zaliha ne može biti negativno.")]
    public int StockQuantity { get; set; }

    public string? ImageBase64 { get; set; }
}
