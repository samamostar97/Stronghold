using MediatR;
using Microsoft.EntityFrameworkCore;
using Stronghold.Application.Common;
using Stronghold.Application.Interfaces;
using Stronghold.Domain.Entities;

namespace Stronghold.Application.Features.Orders.GetUserOrders;

public class GetUserOrdersQueryHandler : IRequestHandler<GetUserOrdersQuery, PagedResult<OrderResponse>>
{
    private readonly IOrderRepository _orderRepository;

    public GetUserOrdersQueryHandler(IOrderRepository orderRepository)
    {
        _orderRepository = orderRepository;
    }

    public async Task<PagedResult<OrderResponse>> Handle(GetUserOrdersQuery request, CancellationToken cancellationToken)
    {
        IQueryable<Order> query = _orderRepository.QueryAll()
            .Include(o => o.User)
            .Include(o => o.Items).ThenInclude(i => i.Product)
            .Where(o => o.UserId == request.UserId)
            .OrderByDescending(o => o.CreatedAt);

        var totalCount = await query.CountAsync(cancellationToken);

        var orders = await query
            .Skip((request.PageNumber - 1) * request.PageSize)
            .Take(request.PageSize)
            .ToListAsync(cancellationToken);

        return new PagedResult<OrderResponse>
        {
            Items = orders.Select(o => OrderMappings.ToResponse(o)).ToList(),
            TotalCount = totalCount,
            TotalPages = (int)Math.Ceiling(totalCount / (double)request.PageSize),
            CurrentPage = request.PageNumber,
            PageSize = request.PageSize
        };
    }
}
