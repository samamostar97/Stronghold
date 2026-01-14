using Microsoft.EntityFrameworkCore;
using Stronghold.Application.Common;
using Stronghold.Application.IRepositories;
using Stronghold.Core.Entities;
using Stronghold.Core.Enums;
using Stronghold.Infrastructure.Data;

namespace Stronghold.Infrastructure.Repositories;

public class UserRepository : BaseRepository<User, int>, IUserRepository
{
    private readonly StrongholdDbContext _context;

    public UserRepository(StrongholdDbContext context) : base(context)
    {
        _context = context;
    }

    public Task<bool> UsernameExistsAsync(string username, int? excludeUserId = null)
    {
        username = username.Trim();
        var q = _context.Users.Where(u => u.Username == username);

        if (excludeUserId.HasValue)
            q = q.Where(u => u.Id != excludeUserId.Value);

        return q.AnyAsync();
    }

    public Task<bool> EmailExistsAsync(string email, int? excludeUserId = null)
    {
        email = email.Trim();
        var q = _context.Users.Where(u => u.Email == email);

        if (excludeUserId.HasValue)
            q = q.Where(u => u.Id != excludeUserId.Value);

        return q.AnyAsync();
    }
}

