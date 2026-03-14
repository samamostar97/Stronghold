using MediatR;
using Microsoft.EntityFrameworkCore;
using Stronghold.Application.Common;
using Stronghold.Application.Interfaces;

namespace Stronghold.Application.Features.GymVisits.GetEligibleForCheckIn;

public class GetEligibleForCheckInQueryHandler : IRequestHandler<GetEligibleForCheckInQuery, PagedResult<EligibleMemberResponse>>
{
    private readonly IUserMembershipRepository _membershipRepository;
    private readonly IGymVisitRepository _gymVisitRepository;

    public GetEligibleForCheckInQueryHandler(
        IUserMembershipRepository membershipRepository,
        IGymVisitRepository gymVisitRepository)
    {
        _membershipRepository = membershipRepository;
        _gymVisitRepository = gymVisitRepository;
    }

    public async Task<PagedResult<EligibleMemberResponse>> Handle(GetEligibleForCheckInQuery request, CancellationToken cancellationToken)
    {
        // Get user IDs that are currently checked in (no check-out yet)
        var checkedInUserIds = await _gymVisitRepository.Query()
            .Where(v => v.CheckOutAt == null)
            .Select(v => v.UserId)
            .ToListAsync(cancellationToken);

        IQueryable<Domain.Entities.UserMembership> query = _membershipRepository.QueryAll()
            .Include(m => m.User)
            .Include(m => m.MembershipPackage);

        query = query.Where(m => m.IsActive && m.EndDate > DateTime.UtcNow && !checkedInUserIds.Contains(m.UserId));

        if (!string.IsNullOrWhiteSpace(request.Search))
        {
            var search = request.Search.ToLower();
            query = query.Where(m =>
                m.User.FirstName.ToLower().Contains(search) ||
                m.User.LastName.ToLower().Contains(search) ||
                m.User.Username.ToLower().Contains(search));
        }

        query = query.OrderBy(m => m.User.FirstName).ThenBy(m => m.User.LastName);

        var totalCount = await query.CountAsync(cancellationToken);

        var items = await query
            .Skip((request.PageNumber - 1) * request.PageSize)
            .Take(request.PageSize)
            .ToListAsync(cancellationToken);

        return new PagedResult<EligibleMemberResponse>
        {
            Items = items.Select(m => new EligibleMemberResponse
            {
                UserId = m.UserId,
                UserFullName = $"{m.User.FirstName} {m.User.LastName}",
                MembershipPackageName = m.MembershipPackage.Name
            }).ToList(),
            TotalCount = totalCount,
            TotalPages = (int)Math.Ceiling(totalCount / (double)request.PageSize),
            CurrentPage = request.PageNumber,
            PageSize = request.PageSize
        };
    }
}
