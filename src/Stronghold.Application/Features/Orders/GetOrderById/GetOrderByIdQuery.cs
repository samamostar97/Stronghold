using MediatR;
using Stronghold.Application.Common;

namespace Stronghold.Application.Features.Orders.GetOrderById;

[AuthorizeRole("Admin")]
[AuthorizeRole("User")]
public class GetOrderByIdQuery : IRequest<OrderResponse>
{
    public int Id { get; set; }
}
