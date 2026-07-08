using System.ComponentModel.DataAnnotations;

namespace Stronghold.Application.DTOs.Cart;

public class AddCartItemRequest
{
    [Range(1, int.MaxValue, ErrorMessage = "Odaberite suplement.")]
    public int SupplementId { get; set; }

    [Range(1, 100, ErrorMessage = "Količina mora biti između 1 i 100.")]
    public int Quantity { get; set; } = 1;
}
