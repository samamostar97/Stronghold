using MediatR;
using Microsoft.EntityFrameworkCore;
using Stronghold.Application.Interfaces;
using Stronghold.Domain.Enums;

namespace Stronghold.Application.Features.Reports.OrderRevenueReport;

public class OrderRevenueReportQueryHandler : IRequestHandler<OrderRevenueReportQuery, ReportResult>
{
    private readonly IOrderRepository _orderRepository;
    private readonly IReportService _reportService;

    public OrderRevenueReportQueryHandler(IOrderRepository orderRepository, IReportService reportService)
    {
        _orderRepository = orderRepository;
        _reportService = reportService;
    }

    public async Task<ReportResult> Handle(OrderRevenueReportQuery request, CancellationToken cancellationToken)
    {
        var orders = await _orderRepository.QueryAll()
            .Include(o => o.User)
            .Where(o => o.Status == OrderStatus.Confirmed || o.Status == OrderStatus.Shipped)
            .Where(o => o.CreatedAt >= request.From && o.CreatedAt <= request.To)
            .OrderByDescending(o => o.CreatedAt)
            .ToListAsync(cancellationToken);

        var data = new OrderRevenueReportData
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

        return request.Format.ToLower() == "excel"
            ? _reportService.GenerateOrderRevenueReportExcel(data)
            : _reportService.GenerateOrderRevenueReportPdf(data);
    }
}
