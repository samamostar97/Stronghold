using Stronghold.Application.Common;
using Stronghold.Application.Features.Orders.DTOs;
using Stronghold.Core.Entities;

namespace Stronghold.Application.IRepositories;

public interface IOrderRepository
{
    Task<IReadOnlyList<Order>> GetAllAsync(OrderFilter? filter, CancellationToken cancellationToken = default);
    Task<PagedResult<Order>> GetPagedAsync(OrderFilter filter, CancellationToken cancellationToken = default);
    Task<Order?> GetByIdWithDetailsAsync(int orderId, CancellationToken cancellationToken = default);
    Task<PagedResult<Order>> GetUserOrdersPagedAsync(
        int userId,
        OrderFilter filter,
        CancellationToken cancellationToken = default);
    Task<IReadOnlyList<Supplement>> GetSupplementsByIdsAsync(
        IReadOnlyCollection<int> supplementIds,
        CancellationToken cancellationToken = default);
    Task<Order?> GetByStripePaymentIdAsync(string paymentIntentId, CancellationToken cancellationToken = default);
    Task<IReadOnlyList<Order>> GetDeliveredForRecommendationAsync(int userId, CancellationToken cancellationToken = default);
    Task<bool> TryAddAsync(Order order, CancellationToken cancellationToken = default);
    Task UpdateAsync(Order order, CancellationToken cancellationToken = default);
    Task<User?> GetUserByIdAsync(int userId, CancellationToken cancellationToken = default);
}
