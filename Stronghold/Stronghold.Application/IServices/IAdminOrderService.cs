using Stronghold.Application.Common;
using Stronghold.Application.DTOs.AdminOrderDTO;
using Stronghold.Application.Filters;

namespace Stronghold.Application.IServices
{
    public interface IAdminOrderService
    {
        Task<IEnumerable<OrdersDTO>> GetAllAsync(OrderQueryFilter? filter);
        Task<PagedResult<OrdersDTO>> GetPagedAsync(PaginationRequest pagination, OrderQueryFilter? filter);
        Task<OrdersDTO> GetByIdAsync(int id);
        Task<OrdersDTO> MarkAsDeliveredAsync(int orderId);
    }
}
