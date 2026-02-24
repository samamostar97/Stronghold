namespace Stronghold.Application.IServices;

public interface IStripePaymentService
{
    Task<StripePaymentIntentResult> CreatePaymentIntentAsync(
        long amountMinorUnits,
        string currency,
        IDictionary<string, string> metadata);
    Task<StripePaymentIntentResult> GetPaymentIntentAsync(string paymentIntentId);
    Task RefundPaymentIntentAsync(string paymentIntentId);
}

public class StripePaymentIntentResult
{
    public string Id { get; set; } = string.Empty;
    public string ClientSecret { get; set; } = string.Empty;
    public string Status { get; set; } = string.Empty;
    public long Amount { get; set; }
    public IDictionary<string, string> Metadata { get; set; } = new Dictionary<string, string>();
}
