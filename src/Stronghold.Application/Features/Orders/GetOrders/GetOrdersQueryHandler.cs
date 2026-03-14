using MediatR;
using Microsoft.EntityFrameworkCore;
using Stronghold.Application.Common;
using Stronghold.Application.Interfaces;
using Stronghold.Domain.Entities;
using Stronghold.Domain.Enums;

namespace Stronghold.Application.Features.Orders.GetOrders;

public class GetOrdersQueryHandler : IRequestHandler<GetOrdersQuery, PagedResult<OrderResponse>>
{
    private readonly IOrderRepository _orderRepository;

    public GetOrdersQueryHandler(IOrderRepository orderRepository)
    {
        _orderRepository = orderRepository;
    }

    public async Task<PagedResult<OrderResponse>> Handle(GetOrdersQuery request, CancellationToken cancellationToken)
    {
        IQueryable<Order> query = _orderRepository.QueryAll()
            .Include(o => o.User)
            .Include(o => o.Items).ThenInclude(i => i.Product);

        if (!string.IsNullOrWhiteSpace(request.Status) && Enum.TryParse<OrderStatus>(request.Status, true, out var status))
            query = query.Where(o => o.Status == status);

        if (request.UserId.HasValue)
            query = query.Where(o => o.UserId == request.UserId.Value);

        if (request.FromDate.HasValue)
            query = query.Where(o => o.CreatedAt >= request.FromDate.Value);

        if (request.ToDate.HasValue)
            query = query.Where(o => o.CreatedAt <= request.ToDate.Value);

        if (!string.IsNullOrWhiteSpace(request.Search))
        {
            var search = request.Search.ToLower();
            query = query.Where(o =>
                o.User.FirstName.ToLower().Contains(search) ||
                o.User.LastName.ToLower().Contains(search) ||
                o.DeliveryAddress.ToLower().Contains(search));
        }

        query = request.OrderBy?.ToLower() switch
        {
            "totalamount" => request.OrderDescending ? query.OrderByDescending(o => o.TotalAmount) : query.OrderBy(o => o.TotalAmount),
            "status" => request.OrderDescending ? query.OrderByDescending(o => o.Status) : query.OrderBy(o => o.Status),
            _ => request.OrderDescending ? query.OrderByDescending(o => o.CreatedAt) : query.OrderBy(o => o.CreatedAt)
        };

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
