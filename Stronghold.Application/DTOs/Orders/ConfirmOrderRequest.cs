using System.ComponentModel.DataAnnotations;

namespace Stronghold.Application.DTOs.Orders;

public class ConfirmOrderRequest
{
    [Required(ErrorMessage = "PaymentIntent identifikator je obavezan.")]
    public string PaymentIntentId { get; set; } = null!;
}
