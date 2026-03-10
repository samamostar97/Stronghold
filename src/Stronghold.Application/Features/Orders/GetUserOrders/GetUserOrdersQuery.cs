using MediatR;
using Stronghold.Application.Common;

namespace Stronghold.Application.Features.Orders.GetUserOrders;

[AuthorizeRole("Admin")]
public class GetUserOrdersQuery : BaseQueryFilter, IRequest<PagedResult<OrderResponse>>
{
    public int UserId { get; set; }
}
