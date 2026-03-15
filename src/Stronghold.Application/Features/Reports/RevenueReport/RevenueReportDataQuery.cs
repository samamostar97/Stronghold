using MediatR;
using Microsoft.EntityFrameworkCore;
using Stronghold.Application.Common;
using Stronghold.Application.Interfaces;
using Stronghold.Domain.Enums;

namespace Stronghold.Application.Features.Reports.RevenueReport;

[AuthorizeRole("Admin")]
public class RevenueReportDataQuery : IRequest<RevenueReportData>
{
    public DateTime From { get; set; }
    public DateTime To { get; set; }
}

public class RevenueReportDataQueryHandler : IRequestHandler<RevenueReportDataQuery, RevenueReportData>
{
    private readonly IOrderRepository _orderRepository;
    private readonly IUserMembershipRepository _membershipRepository;

    public RevenueReportDataQueryHandler(
        IOrderRepository orderRepository,
        IUserMembershipRepository membershipRepository)
    {
        _orderRepository = orderRepository;
        _membershipRepository = membershipRepository;
    }

    public async Task<RevenueReportData> Handle(RevenueReportDataQuery request, CancellationToken cancellationToken)
    {
        var orders = await _orderRepository.Query()
            .Where(o => o.Status == OrderStatus.Confirmed || o.Status == OrderStatus.Shipped)
            .Where(o => o.CreatedAt >= request.From && o.CreatedAt <= request.To)
            .ToListAsync(cancellationToken);

        var memberships = await _membershipRepository.QueryAll()
            .Include(m => m.MembershipPackage)
            .Where(m => m.CreatedAt >= request.From && m.CreatedAt <= request.To)
            .ToListAsync(cancellationToken);

        var orderRevenue = orders.Sum(o => o.TotalAmount);
        var membershipRevenue = memberships.Sum(m => m.MembershipPackage?.Price ?? 0);

        return new RevenueReportData
        {
            From = request.From,
            To = request.To,
            OrderRevenue = orderRevenue,
            MembershipRevenue = membershipRevenue,
            TotalRevenue = orderRevenue + membershipRevenue,
            OrderCount = orders.Count,
            MembershipCount = memberships.Count
        };
    }
}
