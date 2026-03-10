using MediatR;
using Microsoft.EntityFrameworkCore;
using Stronghold.Application.Common;
using Stronghold.Application.Interfaces;

namespace Stronghold.Application.Features.UserMemberships.GetMembershipPayments;

public class GetMembershipPaymentsQueryHandler : IRequestHandler<GetMembershipPaymentsQuery, PagedResult<UserMembershipResponse>>
{
    private readonly IUserMembershipRepository _membershipRepository;

    public GetMembershipPaymentsQueryHandler(IUserMembershipRepository membershipRepository)
    {
        _membershipRepository = membershipRepository;
    }

    public async Task<PagedResult<UserMembershipResponse>> Handle(GetMembershipPaymentsQuery request, CancellationToken cancellationToken)
    {
        IQueryable<Domain.Entities.UserMembership> query = _membershipRepository.Query()
            .Include(m => m.User)
            .Include(m => m.MembershipPackage);

        if (request.IsActive.HasValue)
            query = query.Where(m => m.IsActive == request.IsActive.Value);

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
            _ => request.OrderDescending ? query.OrderByDescending(m => m.CreatedAt) : query.OrderBy(m => m.CreatedAt)
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
