namespace Stronghold.Application.DTOs.Response
{
    public class CheckoutResponse
    {
        public string ClientSecret { get; set; } = string.Empty;
        public string PaymentIntentId { get; set; } = string.Empty;
        public decimal TotalAmount { get; set; }
    }
}
