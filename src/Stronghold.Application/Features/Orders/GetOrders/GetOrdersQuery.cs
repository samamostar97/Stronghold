using MediatR;
using Stronghold.Application.Common;

namespace Stronghold.Application.Features.Orders.GetOrders;

[AuthorizeRole("Admin")]
public class GetOrdersQuery : BaseQueryFilter, IRequest<PagedResult<OrderResponse>>
{
    public string? Status { get; set; }
    public int? UserId { get; set; }
    public DateTime? FromDate { get; set; }
    public DateTime? ToDate { get; set; }
}
