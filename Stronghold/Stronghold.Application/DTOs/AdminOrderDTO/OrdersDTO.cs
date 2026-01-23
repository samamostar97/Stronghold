using Stronghold.Core.Enums;

namespace Stronghold.Application.DTOs.AdminOrderDTO
{
    public class OrdersDTO
    {
        public int Id { get; set; }
        public int UserId { get; set; }
        public string UserFullName { get; set; } = string.Empty;
        public string UserEmail { get; set; } = string.Empty;
        public decimal TotalAmount { get; set; }
        public DateTime PurchaseDate { get; set; }
        public OrderStatus Status { get; set; }
        public string StatusName => Status.ToString();
        public string? StripePaymentId { get; set; }
        public List<OrderItemDTO> OrderItems { get; set; } = new();
    }
}
