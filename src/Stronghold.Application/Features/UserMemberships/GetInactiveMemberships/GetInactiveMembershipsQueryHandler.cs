using MediatR;
using Microsoft.EntityFrameworkCore;
using Stronghold.Application.Common;
using Stronghold.Application.Interfaces;

namespace Stronghold.Application.Features.UserMemberships.GetInactiveMemberships;

public class GetInactiveMembershipsQueryHandler : IRequestHandler<GetInactiveMembershipsQuery, PagedResult<UserMembershipResponse>>
{
    private readonly IUserMembershipRepository _membershipRepository;

    public GetInactiveMembershipsQueryHandler(IUserMembershipRepository membershipRepository)
    {
        _membershipRepository = membershipRepository;
    }

    public async Task<PagedResult<UserMembershipResponse>> Handle(GetInactiveMembershipsQuery request, CancellationToken cancellationToken)
    {
        IQueryable<Domain.Entities.UserMembership> query = _membershipRepository.QueryAll()
            .Include(m => m.User)
            .Include(m => m.MembershipPackage);

        query = query.Where(m => !m.IsActive);

        if (!string.IsNullOrWhiteSpace(request.Status))
        {
            var now = DateTime.UtcNow;
            query = request.Status.ToLower() switch
            {
                "expired" => query.Where(m => m.EndDate <= now),
                "cancelled" => query.Where(m => m.EndDate > now),
                _ => query
            };
        }

        if (!string.IsNullOrWhiteSpace(request.Search))
        {
            var search = request.Search.ToLower();
            query = query.Where(m =>
                m.User.FirstName.ToLower().Contains(search) ||
                m.User.LastName.ToLower().Contains(search) ||
                m.User.Username.ToLower().Contains(search) ||
                m.MembershipPackage.Name.ToLower().Contains(search));
        }

        query = request.OrderBy?.ToLower() switch
        {
            "startdate" => request.OrderDescending ? query.OrderByDescending(m => m.StartDate) : query.OrderBy(m => m.StartDate),
            "enddate" => request.OrderDescending ? query.OrderByDescending(m => m.EndDate) : query.OrderBy(m => m.EndDate),
            _ => query.OrderByDescending(m => m.CreatedAt)
        };

        var totalCount = await query.CountAsync(cancellationToken);

        var items = await query
            .Skip((request.PageNumber - 1) * request.PageSize)
            .Take(request.PageSize)
            .ToListAsync(cancellationToken);

        return new PagedResult<UserMembershipResponse>
        {
            Items = items.Select(UserMembershipMappings.ToResponse).ToList(),
            TotalCount = totalCount,
            TotalPages = (int)Math.Ceiling(totalCount / (double)request.PageSize),
            CurrentPage = request.PageNumber,
            PageSize = request.PageSize
        };
    }
}
