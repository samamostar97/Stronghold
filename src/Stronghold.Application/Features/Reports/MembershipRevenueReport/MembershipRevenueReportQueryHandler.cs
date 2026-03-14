using MediatR;
using Microsoft.EntityFrameworkCore;
using Stronghold.Application.Interfaces;

namespace Stronghold.Application.Features.Reports.MembershipRevenueReport;

public class MembershipRevenueReportQueryHandler : IRequestHandler<MembershipRevenueReportQuery, ReportResult>
{
    private readonly IUserMembershipRepository _membershipRepository;
    private readonly IReportService _reportService;

    public MembershipRevenueReportQueryHandler(
        IUserMembershipRepository membershipRepository,
        IReportService reportService)
    {
        _membershipRepository = membershipRepository;
        _reportService = reportService;
    }

    public async Task<ReportResult> Handle(MembershipRevenueReportQuery request, CancellationToken cancellationToken)
    {
        var memberships = await _membershipRepository.QueryAll()
            .Include(m => m.User)
            .Include(m => m.MembershipPackage)
            .Where(m => m.CreatedAt >= request.From && m.CreatedAt <= request.To)
            .OrderByDescending(m => m.CreatedAt)
            .ToListAsync(cancellationToken);

        var data = new MembershipRevenueReportData
        {
            From = request.From,
            To = request.To,
            TotalRevenue = memberships.Sum(m => m.MembershipPackage?.Price ?? 0),
            TotalMemberships = memberships.Count,
            Items = memberships.Select(m => new MembershipRevenueItem
            {
                MembershipId = m.Id,
                UserName = $"{m.User.FirstName} {m.User.LastName}",
                PackageName = m.MembershipPackage?.Name ?? "-",
                Price = m.MembershipPackage?.Price ?? 0,
                StartDate = m.StartDate,
                EndDate = m.EndDate
            }).ToList()
        };

        return request.Format.ToLower() == "excel"
            ? _reportService.GenerateMembershipRevenueReportExcel(data)
            : _reportService.GenerateMembershipRevenueReportPdf(data);
    }
}
