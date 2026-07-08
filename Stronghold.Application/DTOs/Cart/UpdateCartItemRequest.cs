using System.ComponentModel.DataAnnotations;

namespace Stronghold.Application.DTOs.Cart;

public class UpdateCartItemRequest
{
    [Range(1, 100, ErrorMessage = "Količina mora biti između 1 i 100.")]
    public int Quantity { get; set; }
}
