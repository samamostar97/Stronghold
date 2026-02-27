using Stronghold.Core.Entities;

namespace Stronghold.Application.IServices;

public interface IOrderEmailService
{
    Task SendOrderConfirmationAsync(User user, Order order, IReadOnlyList<OrderItem> items, IReadOnlyList<Supplement> supplements);
}
