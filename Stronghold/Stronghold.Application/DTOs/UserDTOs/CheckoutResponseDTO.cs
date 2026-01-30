namespace Stronghold.Application.DTOs.UserDTOs
{
    public class CheckoutResponseDTO
    {
        public string ClientSecret { get; set; } = string.Empty;
        public string PaymentIntentId { get; set; } = string.Empty;
        public decimal TotalAmount { get; set; }
    }
}
