using Stronghold.Application.Common;
using Stronghold.Application.DTOs.Request;
using Stronghold.Application.DTOs.Response;
using Stronghold.Application.Filters;

namespace Stronghold.Application.IServices
{
    public interface IOrderService
    {
        Task<IEnumerable<OrderResponse>> GetAllAsync(OrderQueryFilter? filter);
        Task<PagedResult<OrderResponse>> GetPagedAsync(OrderQueryFilter filter);
        Task<OrderResponse> GetByIdAsync(int id);
        Task<OrderResponse> MarkAsDeliveredAsync(int orderId);
        Task<OrderResponse> CancelOrderAsync(int orderId, string? reason);

        // User-specific methods
        Task<PagedResult<UserOrderResponse>> GetOrdersByUserIdAsync(int userId, OrderQueryFilter filter);

        // Checkout methods (merged from ICheckoutService)
        Task<CheckoutResponse> CreatePaymentIntentAsync(int userId, CheckoutRequest request);
        Task<UserOrderResponse> ConfirmOrderAsync(int userId, ConfirmOrderRequest request);
    }
}
