namespace Stronghold.Application.Interfaces;

public interface IStripeService
{
    Task<PaymentIntentResult> CreatePaymentIntentAsync(decimal amount);
}
