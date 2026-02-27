using Stripe;
using Stronghold.Application.IServices;

namespace Stronghold.Infrastructure.Services;

public class StripePaymentService : IStripePaymentService
{
    private readonly PaymentIntentService _paymentIntentService;
    private readonly RefundService _refundService;

    public StripePaymentService()
    {
        _paymentIntentService = new PaymentIntentService();
        _refundService = new RefundService();
    }

    public async Task<StripePaymentIntentResult> CreatePaymentIntentAsync(
        long amountMinorUnits,
        string currency,
        IDictionary<string, string> metadata)
    {
        try
        {
            var options = new PaymentIntentCreateOptions
            {
                Amount = amountMinorUnits,
                Currency = currency,
                Metadata = metadata.ToDictionary(x => x.Key, x => x.Value)
            };

            var intent = await _paymentIntentService.CreateAsync(options);
            return Map(intent);
        }
        catch (StripeException ex)
        {
            throw new InvalidOperationException($"Kreiranje uplate nije uspjelo: {ex.Message}");
        }
    }

    public async Task<StripePaymentIntentResult> GetPaymentIntentAsync(string paymentIntentId)
    {
        try
        {
            var intent = await _paymentIntentService.GetAsync(paymentIntentId);
            return Map(intent);
        }
        catch (StripeException ex)
        {
            throw new InvalidOperationException($"Provjera uplate nije uspjela: {ex.Message}");
        }
    }

    public async Task<StripePaymentIntentResult> VerifyPaymentAsync(string paymentIntentId, int userId)
    {
        var result = await GetPaymentIntentAsync(paymentIntentId);

        if (!string.Equals(result.Status, "succeeded", StringComparison.OrdinalIgnoreCase))
            throw new InvalidOperationException("Uplata nije uspjela.");

        if (!result.Metadata.TryGetValue("userId", out var metadataUserId)
            || metadataUserId != userId.ToString())
            throw new InvalidOperationException("Neovlasteni pristup uplati.");

        return result;
    }

    public async Task RefundPaymentIntentAsync(string paymentIntentId)
    {
        try
        {
            await _refundService.CreateAsync(new RefundCreateOptions
            {
                PaymentIntent = paymentIntentId
            });
        }
        catch (StripeException ex)
        {
            throw new InvalidOperationException($"Stripe refund nije uspio: {ex.Message}");
        }
    }

    private static StripePaymentIntentResult Map(PaymentIntent paymentIntent)
    {
        return new StripePaymentIntentResult
        {
            Id = paymentIntent.Id,
            ClientSecret = paymentIntent.ClientSecret ?? string.Empty,
            Status = paymentIntent.Status ?? string.Empty,
            Amount = paymentIntent.Amount,
            Metadata = paymentIntent.Metadata ?? new Dictionary<string, string>()
        };
    }
}
