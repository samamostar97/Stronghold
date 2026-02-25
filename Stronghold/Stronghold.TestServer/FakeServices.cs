using Stronghold.Application.IServices;

namespace Stronghold.TestServer;

public class FakeStripePaymentService : IStripePaymentService
{
    private int _counter;

    public Task<StripePaymentIntentResult> CreatePaymentIntentAsync(
        long amountMinorUnits, string currency, IDictionary<string, string> metadata)
    {
        var id = $"pi_fake_{Interlocked.Increment(ref _counter):D6}";
        return Task.FromResult(new StripePaymentIntentResult
        {
            Id = id,
            ClientSecret = $"{id}_secret_fake",
            Status = "succeeded",
            Amount = amountMinorUnits,
            Metadata = metadata
        });
    }

    public Task<StripePaymentIntentResult> GetPaymentIntentAsync(string paymentIntentId)
    {
        return Task.FromResult(new StripePaymentIntentResult
        {
            Id = paymentIntentId,
            ClientSecret = $"{paymentIntentId}_secret_fake",
            Status = "succeeded",
            Amount = 0,
            Metadata = new Dictionary<string, string>()
        });
    }

    public Task RefundPaymentIntentAsync(string paymentIntentId)
    {
        Console.WriteLine($"[FakeStripe] Refund requested for: {paymentIntentId}");
        return Task.CompletedTask;
    }
}

public class FakeEmailService : IEmailService
{
    public Task SendEmailAsync(string toEmail, string subject, string body)
    {
        Console.WriteLine($"[FakeEmail] To: {toEmail} | Subject: {subject}");
        return Task.CompletedTask;
    }
}
