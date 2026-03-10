using MediatR;
using Microsoft.EntityFrameworkCore;
using Stronghold.Application.Common;
using Stronghold.Application.Interfaces;
using Stronghold.Domain.Enums;

namespace Stronghold.Application.Features.Users.GetUsers;

public class GetUsersQueryHandler : IRequestHandler<GetUsersQuery, PagedResult<UserResponse>>
{
    private readonly IUserRepository _userRepository;

    public GetUsersQueryHandler(IUserRepository userRepository)
    {
        _userRepository = userRepository;
    }

    public async Task<PagedResult<UserResponse>> Handle(GetUsersQuery request, CancellationToken cancellationToken)
    {
        var query = _userRepository.Query().Where(u => u.Role == Role.User);

        if (!string.IsNullOrWhiteSpace(request.Search))
        {
            var search = request.Search.ToLower();
            query = query.Where(u =>
                u.FirstName.ToLower().Contains(search) ||
                u.LastName.ToLower().Contains(search) ||
                u.Username.ToLower().Contains(search) ||
                u.Email.ToLower().Contains(search));
        }

        query = request.OrderBy?.ToLower() switch
        {
            "username" => request.OrderDescending ? query.OrderByDescending(u => u.Username) : query.OrderBy(u => u.Username),
            "email" => request.OrderDescending ? query.OrderByDescending(u => u.Email) : query.OrderBy(u => u.Email),
            "firstname" => request.OrderDescending ? query.OrderByDescending(u => u.FirstName) : query.OrderBy(u => u.FirstName),
            "lastname" => request.OrderDescending ? query.OrderByDescending(u => u.LastName) : query.OrderBy(u => u.LastName),
            _ => request.OrderDescending ? query.OrderByDescending(u => u.CreatedAt) : query.OrderBy(u => u.CreatedAt)
        };

        var totalCount = await query.CountAsync(cancellationToken);

        var users = await query
            .Skip((request.PageNumber - 1) * request.PageSize)
            .Take(request.PageSize)
            .ToListAsync(cancellationToken);

        return new PagedResult<UserResponse>
        {
            Items = users.Select(UserMappings.ToResponse).ToList(),
            TotalCount = totalCount,
            TotalPages = (int)Math.Ceiling(totalCount / (double)request.PageSize),
            CurrentPage = request.PageNumber,
            PageSize = request.PageSize
        };
    }
}
