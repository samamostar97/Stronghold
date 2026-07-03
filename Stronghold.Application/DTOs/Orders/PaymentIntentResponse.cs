namespace Stronghold.Application.DTOs.Orders;

public class PaymentIntentResponse
{
    public string PaymentIntentId { get; set; } = null!;
    public string ClientSecret { get; set; } = null!;
    public decimal Amount { get; set; }
    public string PublishableKey { get; set; } = null!;
}
