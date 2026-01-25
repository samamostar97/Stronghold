using Stronghold.Application.DTOs.AdminOrderDTO;
using Stronghold.Core.Enums;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Stronghold.Application.DTOs.UserDTOs
{
    public class UserOrdersDTO
    {
        public int Id { get; set; }
        public decimal TotalAmount { get; set; }
        public DateTime PurchaseDate { get; set; }
        public OrderStatus Status { get; set; }
        public string StatusName => Status.ToString();
        //public string? StripePaymentId { get; set; }
        public List<UserOrderItemsDTO> OrderItems { get; set; } = new();
    }
}
