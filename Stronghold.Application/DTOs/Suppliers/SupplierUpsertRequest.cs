using System.ComponentModel.DataAnnotations;

namespace Stronghold.Application.DTOs.Suppliers;

public class SupplierUpsertRequest
{
    [Required(ErrorMessage = "Unesite naziv dobavljača.")]
    [MaxLength(100, ErrorMessage = "Naziv dobavljača može imati najviše 100 znakova.")]
    public string Name { get; set; } = null!;

    [Required(ErrorMessage = "Unesite kontakt e-mail.")]
    [EmailAddress(ErrorMessage = "Unesite validnu e-mail adresu u formatu: ime@domena.com")]
    [MaxLength(100, ErrorMessage = "E-mail može imati najviše 100 znakova.")]
    public string ContactEmail { get; set; } = null!;

    [Required(ErrorMessage = "Unesite kontakt telefon.")]
    [RegularExpression(@"^[0-9+\-\/\s]{6,30}$", ErrorMessage = "Unesite validan broj telefona u formatu: +387-61-123-456")]
    public string ContactPhone { get; set; } = null!;
}
