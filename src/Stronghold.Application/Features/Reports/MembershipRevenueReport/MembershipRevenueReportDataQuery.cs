using MediatR;
using Microsoft.EntityFrameworkCore;
using Stronghold.Application.Common;
using Stronghold.Application.Interfaces;

namespace Stronghold.Application.Features.Reports.MembershipRevenueReport;

[AuthorizeRole("Admin")]
public class MembershipRevenueReportDataQuery : IRequest<MembershipRevenueReportData>
{
    public DateTime From { get; set; }
    public DateTime To { get; set; }
}

public class MembershipRevenueReportDataQueryHandler : IRequestHandler<MembershipRevenueReportDataQuery, MembershipRevenueReportData>
{
    private readonly IUserMembershipRepository _membershipRepository;

    public MembershipRevenueReportDataQueryHandler(IUserMembershipRepository membershipRepository)
    {
        _membershipRepository = membershipRepository;
    }

    public async Task<MembershipRevenueReportData> Handle(MembershipRevenueReportDataQuery request, CancellationToken cancellationToken)
    {
        var memberships = await _membershipRepository.QueryAll()
            .Include(m => m.User)
            .Include(m => m.MembershipPackage)
            .Where(m => m.CreatedAt >= request.From && m.CreatedAt <= request.To)
            .OrderByDescending(m => m.CreatedAt)
            .ToListAsync(cancellationToken);

        return new MembershipRevenueReportData
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
    }
}
