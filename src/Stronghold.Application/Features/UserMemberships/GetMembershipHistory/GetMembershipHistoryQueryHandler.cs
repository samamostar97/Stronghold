using MediatR;
using Microsoft.EntityFrameworkCore;
using Stronghold.Application.Common;
using Stronghold.Application.Interfaces;
using Stronghold.Domain.Exceptions;

namespace Stronghold.Application.Features.UserMemberships.GetMembershipHistory;

public class GetMembershipHistoryQueryHandler : IRequestHandler<GetMembershipHistoryQuery, PagedResult<UserMembershipResponse>>
{
    private readonly IUserMembershipRepository _membershipRepository;
    private readonly IUserRepository _userRepository;

    public GetMembershipHistoryQueryHandler(
        IUserMembershipRepository membershipRepository,
        IUserRepository userRepository)
    {
        _membershipRepository = membershipRepository;
        _userRepository = userRepository;
    }

    public async Task<PagedResult<UserMembershipResponse>> Handle(GetMembershipHistoryQuery request, CancellationToken cancellationToken)
    {
        _ = await _userRepository.GetByIdAsync(request.UserId)
            ?? throw new NotFoundException("Korisnik", request.UserId);

        IQueryable<Domain.Entities.UserMembership> query = _membershipRepository.Query()
            .Include(m => m.User)
            .Include(m => m.MembershipPackage)
            .Where(m => m.UserId == request.UserId);

        query = request.OrderDescending
            ? query.OrderByDescending(m => m.StartDate)
            : query.OrderBy(m => m.StartDate);

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
