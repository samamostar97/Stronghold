using MediatR;
using Microsoft.EntityFrameworkCore;
using Stronghold.Application.Common;
using Stronghold.Application.Interfaces;
using Stronghold.Domain.Enums;

namespace Stronghold.Application.Features.Reports.OrderRevenueReport;

[AuthorizeRole("Admin")]
public class OrderRevenueReportDataQuery : IRequest<OrderRevenueReportData>
{
    public DateTime From { get; set; }
    public DateTime To { get; set; }
}

public class OrderRevenueReportDataQueryHandler : IRequestHandler<OrderRevenueReportDataQuery, OrderRevenueReportData>
{
    private readonly IOrderRepository _orderRepository;

    public OrderRevenueReportDataQueryHandler(IOrderRepository orderRepository)
    {
        _orderRepository = orderRepository;
    }

    public async Task<OrderRevenueReportData> Handle(OrderRevenueReportDataQuery request, CancellationToken cancellationToken)
    {
        var orders = await _orderRepository.QueryAll()
            .Include(o => o.User)
            .Where(o => o.Status == OrderStatus.Confirmed || o.Status == OrderStatus.Shipped)
            .Where(o => o.CreatedAt >= request.From && o.CreatedAt <= request.To)
            .OrderByDescending(o => o.CreatedAt)
            .ToListAsync(cancellationToken);

        return new OrderRevenueReportData
        {
            From = request.From,
            To = request.To,
            TotalRevenue = orders.Sum(o => o.TotalAmount),
            TotalOrders = orders.Count,
            Items = orders.Select(o => new OrderRevenueItem
            {
                OrderId = o.Id,
                UserName = $"{o.User.FirstName} {o.User.LastName}",
                TotalAmount = o.TotalAmount,
                Status = o.Status.ToString(),
                CreatedAt = o.CreatedAt
            }).ToList()
        };
    }
}
