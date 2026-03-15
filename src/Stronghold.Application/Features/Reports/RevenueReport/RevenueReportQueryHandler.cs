using MediatR;
using Microsoft.EntityFrameworkCore;
using Stronghold.Application.Interfaces;
using Stronghold.Domain.Enums;

namespace Stronghold.Application.Features.Reports.RevenueReport;

public class RevenueReportQueryHandler : IRequestHandler<RevenueReportQuery, ReportResult>
{
    private readonly IOrderRepository _orderRepository;
    private readonly IUserMembershipRepository _membershipRepository;
    private readonly IReportService _reportService;

    public RevenueReportQueryHandler(
        IOrderRepository orderRepository,
        IUserMembershipRepository membershipRepository,
        IReportService reportService)
    {
        _orderRepository = orderRepository;
        _membershipRepository = membershipRepository;
        _reportService = reportService;
    }

    public async Task<ReportResult> Handle(RevenueReportQuery request, CancellationToken cancellationToken)
    {
        var orders = await _orderRepository.QueryAll()
            .Include(o => o.User)
            .Where(o => o.Status == OrderStatus.Confirmed || o.Status == OrderStatus.Shipped)
            .Where(o => o.CreatedAt >= request.From && o.CreatedAt <= request.To)
            .OrderByDescending(o => o.CreatedAt)
            .ToListAsync(cancellationToken);

        var memberships = await _membershipRepository.QueryAll()
            .Include(m => m.User)
            .Include(m => m.MembershipPackage)
            .Where(m => m.CreatedAt >= request.From && m.CreatedAt <= request.To)
            .OrderByDescending(m => m.CreatedAt)
            .ToListAsync(cancellationToken);

        var orderRevenue = orders.Sum(o => o.TotalAmount);
        var membershipRevenue = memberships.Sum(m => m.MembershipPackage?.Price ?? 0);

        var data = new RevenueReportData
        {
            From = request.From,
            To = request.To,
            OrderRevenue = orderRevenue,
            MembershipRevenue = membershipRevenue,
            TotalRevenue = orderRevenue + membershipRevenue,
            OrderCount = orders.Count,
            MembershipCount = memberships.Count,
            OrderItems = orders.Select(o => new OrderRevenueItem
            {
                OrderId = o.Id,
                UserName = !string.IsNullOrEmpty(o.UserFullName) ? o.UserFullName : $"{o.User.FirstName} {o.User.LastName}",
                TotalAmount = o.TotalAmount,
                Status = o.Status.ToString(),
                CreatedAt = o.CreatedAt
            }).ToList(),
            MembershipItems = memberships.Select(m => new MembershipRevenueItem
            {
                MembershipId = m.Id,
                UserName = !string.IsNullOrEmpty(m.UserFullName) ? m.UserFullName : $"{m.User.FirstName} {m.User.LastName}",
                PackageName = !string.IsNullOrEmpty(m.PackageName) ? m.PackageName : m.MembershipPackage?.Name ?? "-",
                Price = m.PackagePrice > 0 ? m.PackagePrice : m.MembershipPackage?.Price ?? 0,
                StartDate = m.StartDate,
                EndDate = m.EndDate
            }).ToList()
        };

        return request.Format.ToLower() == "excel"
            ? _reportService.GenerateRevenueReportExcel(data)
            : _reportService.GenerateRevenueReportPdf(data);
    }
}
