using Microsoft.EntityFrameworkCore;
using Stronghold.Application.DTOs.AdminOrderDTO;
using Stronghold.Application.DTOs.UserDTOs;
using Stronghold.Application.IRepositories;
using Stronghold.Application.IServices;
using Stronghold.Core.Entities;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Stronghold.Infrastructure.Services
{
    public class UserOrderService:IUserOrderService
    {
        private readonly IRepository<Order, int> _orderRepository;
        public UserOrderService(IRepository<Order,int> orderRepository)
        {
            _orderRepository = orderRepository;
        }

        public async Task<IEnumerable<UserOrdersDTO>> GetOrderList(int userId)
        {
            var orderList = _orderRepository.AsQueryable().Where(x => x.UserId == userId).Include(x => x.OrderItems).ThenInclude(x => x.Supplement);
            var orderListDTO = await orderList.Select(x => new UserOrdersDTO()
            {
                Id = x.Id,
                TotalAmount = x.TotalAmount,
                PurchaseDate = x.PurchaseDate,
                Status = x.Status,
                OrderItems = x.OrderItems.Select(x => new UserOrderItemsDTO()
                {
                    Id=x.Id,
                    SupplementName = x.Supplement.Name,
                    Quantity = x.Quantity,
                    UnitPrice = x.UnitPrice

                }).ToList()
            }).ToListAsync();
            return orderListDTO;
        }
    }
}
