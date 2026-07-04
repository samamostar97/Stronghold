using System.ComponentModel.DataAnnotations;

namespace Stronghold.Application.DTOs.Orders;

public class CreatePaymentIntentRequest
{
    [MinLength(1, ErrorMessage = "Korpa je prazna.")]
    public List<OrderItemRequest> Items { get; set; } = new();

    [Required(ErrorMessage = "Unesite ulicu i broj za dostavu.")]
    [MaxLength(100, ErrorMessage = "Adresa može imati najviše 100 znakova.")]
    public string DeliveryStreet { get; set; } = null!;

    [Range(1, int.MaxValue, ErrorMessage = "Odaberite grad dostave.")]
    public int DeliveryCityId { get; set; }
}
