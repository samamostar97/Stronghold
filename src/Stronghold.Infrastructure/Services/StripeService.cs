using Stripe;
using Stronghold.Application.Interfaces;

namespace Stronghold.Infrastructure.Services;

public class StripeService : IStripeService
{
    public StripeService()
    {
        StripeConfiguration.ApiKey = Environment.GetEnvironmentVariable("STRIPE_SECRET_KEY");
    }

    public async Task<PaymentIntentResult> CreatePaymentIntentAsync(decimal amount)
    {
        var options = new PaymentIntentCreateOptions
        {
            Amount = (long)(amount * 100),
            Currency = "bam",
            PaymentMethodTypes = new List<string> { "card" }
        };

        var service = new PaymentIntentService();
        var paymentIntent = await service.CreateAsync(options);

        return new PaymentIntentResult
        {
            PaymentIntentId = paymentIntent.Id,
            ClientSecret = paymentIntent.ClientSecret
        };
    }
}
