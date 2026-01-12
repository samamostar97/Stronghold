using Microsoft.EntityFrameworkCore;
using Stronghold.Application.Common;
using Stronghold.Application.DTOs.UserDTOs;
using Stronghold.Application.IRepositories;
using Stronghold.Core.Entities;
using Stronghold.Core.Enums;
using Stronghold.Infrastructure.Data;

namespace Stronghold.Infrastructure.Repositories;

public class UserRepository : BaseRepository<User, int>, IUserRepository
{
    public UserRepository(StrongholdDbContext context) : base(context) { }

    public async Task<PagedResult<User>> SearchPagedAsync(UserSearchRequest request)
    {
        var query = AsQueryable().AsNoTracking();
        if (!string.IsNullOrWhiteSpace(request.Search))
        {
            var s = request.Search.Trim();
            query = query.Where(x =>
                x.FirstName.Contains(s) ||
                x.LastName.Contains(s) ||
                x.Username.Contains(s));
        }

        // Example: order by newest first (optional)
        query = query.OrderByDescending(x => x.CreatedAt);

        return await GetPagedAsync(query, request);
    }
}