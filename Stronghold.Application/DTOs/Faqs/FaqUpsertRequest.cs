using System.ComponentModel.DataAnnotations;

namespace Stronghold.Application.DTOs.Faqs;

public class FaqUpsertRequest
{
    [Required(ErrorMessage = "Unesite pitanje.")]
    [MaxLength(300, ErrorMessage = "Pitanje može imati najviše 300 znakova.")]
    public string Question { get; set; } = null!;

    [Required(ErrorMessage = "Unesite odgovor.")]
    [MaxLength(2000, ErrorMessage = "Odgovor može imati najviše 2000 znakova.")]
    public string Answer { get; set; } = null!;
}
