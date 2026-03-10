using MediatR;
using Stronghold.Application.Common;

namespace Stronghold.Application.Features.Orders.ConfirmOrder;

[AuthorizeRole("Admin")]
[AuthorizeRole("User")]
public class ConfirmOrderCommand : IRequest<OrderResponse>
{
    public int Id { get; set; }
}
