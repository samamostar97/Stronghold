using MediatR;
using Stronghold.Application.Common;

namespace Stronghold.Application.Features.Orders.GetMyOrders;

[AuthorizeRole("User")]
public class GetMyOrdersQuery : BaseQueryFilter, IRequest<PagedResult<OrderResponse>>
{
}
