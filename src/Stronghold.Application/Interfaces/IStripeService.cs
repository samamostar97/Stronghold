namespace Stronghold.Application.Interfaces;

public class PaymentIntentResult
{
    public string PaymentIntentId { get; set; } = string.Empty;
    public string ClientSecret { get; set; } = string.Empty;
}

public interface IStripeService
{
    Task<PaymentIntentResult> CreatePaymentIntentAsync(decimal amount);
}
